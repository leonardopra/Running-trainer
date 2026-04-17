import Foundation

enum ClaudeServiceError: Error {
    case authError(String)
    case rateLimited
    case networkError(String)
}

final class ClaudeService {
    private static let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private static let model = "claude-sonnet-4-6"
    private static let maxRetries = 3

    struct EnrichmentResult {
        var enrichedWeeks: [TrainingWeek]
        var isAuthError: Bool = false
    }

    func enrichPlan(plan: TrainingPlan, apiKey: String, preferences: UserPreferences) async -> EnrichmentResult {
        var enrichedWeeks: [TrainingWeek] = []
        for week in plan.weeks {
            do {
                let enriched = try await enrichWeek(week: week, apiKey: apiKey, goalType: plan.goalType, fitnessLevel: plan.fitnessLevel, preferences: preferences)
                enrichedWeeks.append(enriched)
            } catch ClaudeServiceError.authError {
                enrichedWeeks.append(week)
                let processed = enrichedWeeks.count
                enrichedWeeks.append(contentsOf: plan.weeks.dropFirst(processed))
                return EnrichmentResult(enrichedWeeks: enrichedWeeks, isAuthError: true)
            } catch {
                enrichedWeeks.append(week)
            }
        }
        return EnrichmentResult(enrichedWeeks: enrichedWeeks)
    }

    private func enrichWeek(week: TrainingWeek, apiKey: String, goalType: GoalType, fitnessLevel: FitnessLevel, preferences: UserPreferences) async throws -> TrainingWeek {
        let nonRest = week.workouts.filter { $0.type != .rest }
        if nonRest.isEmpty { return week }

        var profileContext = ""
        if let age = preferences.age {
            let maxHr = 220 - age
            profileContext = "\nRunner profile: age \(age)"
            if let w = preferences.weightKg { profileContext += ", \(Int(w))kg" }
            if let h = preferences.heightCm { profileContext += ", \(Int(h))cm" }
            profileContext += ".\nMax HR ≈ \(maxHr) bpm. Include age-appropriate recovery cues and HR zone guidance."
        }

        let workoutsJSON = nonRest.map { w -> [String: Any] in
            var obj: [String: Any] = ["id": w.id, "type": w.type.rawValue, "title": w.title]
            if let d = w.distanceKm { obj["distanceKm"] = d }
            if let dur = w.durationMinutes { obj["durationMinutes"] = dur }
            return obj
        }
        let workoutsData = try JSONSerialization.data(withJSONObject: workoutsJSON)
        let workoutsStr = String(data: workoutsData, encoding: .utf8) ?? "[]"

        let prompt = "Week \(week.weekNumber): \(week.weekTheme)\nTarget: \(week.targetWeeklyKm)km\nGoal: \(goalType.rawValue) | Level: \(fitnessLevel.rawValue)\(profileContext)\n\nWorkouts to enrich:\n\(workoutsStr)\n\nReturn ONLY a JSON array with this structure for each workout:\n[{\"id\": \"...\", \"description\": \"...\", \"coachingTip\": \"...\"}]\n\nRules: max 60 words per description, direct/practical tone, no markdown."

        let response = try await callWithRetry(apiKey: apiKey, prompt: prompt)
        let enrichments = parseEnrichments(response)
        return applyEnrichments(week: week, enrichments: enrichments)
    }

    func generatePostWorkoutCoaching(workout: Workout, apiKey: String, age: Int?) async -> String? {
        let distStr = workout.actualDistanceKm.map { String(format: "%.2f km", $0) } ?? "unknown distance"
        let durStr = workout.actualDurationMinutes.map { "\($0) min" } ?? "unknown duration"
        let rpeStr = workout.rpe.map { "\($0)/10" } ?? "not logged"
        let feelingStr = workout.feeling?.displayName ?? "not logged"
        let notesStr = workout.notes?.isEmpty == false ? workout.notes! : "none"
        let ageStr = age.map { ", age \($0)" } ?? ""
        let typeLabel = workout.type.displayName
        let prompt = "Athlete\(ageStr) completed a \(typeLabel) (planned: \(workout.distanceKm.map { String(format: "%.1f", $0) } ?? "?") km). Actual: \(distStr), \(durStr). RPE: \(rpeStr). Feeling: \(feelingStr). Notes: \(notesStr). Give 2-3 sentences of honest, practical coaching feedback. Be concise, no markdown."

        return try? await callWithRetry(
            apiKey: apiKey,
            prompt: prompt,
            systemPrompt: "You are an experienced running coach. Give concise, honest, actionable post-workout feedback. Plain text only, no markdown, max 80 words.",
            maxTokens: 256
        ).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func callWithRetry(
        apiKey: String,
        prompt: String,
        systemPrompt: String = "You are an expert running coach. Provide concise, practical workout guidance. Always respond with valid JSON only — no markdown, no code fences.",
        maxTokens: Int = 1024,
        attempt: Int = 0
    ) async throws -> String {
        let body: [String: Any] = [
            "model": Self.model,
            "max_tokens": maxTokens,
            "system": systemPrompt,
            "messages": [["role": "user", "content": prompt]]
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: Self.apiURL)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.timeoutInterval = 60
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0

        if status == 401 { throw ClaudeServiceError.authError("Invalid API key. Check your key in Settings.") }
        if status == 429 {
            if attempt < Self.maxRetries {
                try await Task.sleep(nanoseconds: UInt64(2_000_000_000 * (attempt + 1)))
                return try await callWithRetry(apiKey: apiKey, prompt: prompt, systemPrompt: systemPrompt, maxTokens: maxTokens, attempt: attempt + 1)
            }
            throw ClaudeServiceError.rateLimited
        }
        guard (200...299).contains(status) else {
            throw ClaudeServiceError.networkError("Claude API error: HTTP \(status)")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let content = (json?["content"] as? [[String: Any]])?.first,
              let text = content["text"] as? String else {
            throw ClaudeServiceError.networkError("Unexpected response structure.")
        }
        return text
    }

    private func parseEnrichments(_ response: String) -> [String: (String?, String?)] {
        let cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json\n", with: "")
            .replacingOccurrences(of: "```\n", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return [:]
        }
        var result: [String: (String?, String?)] = [:]
        for item in array {
            guard let id = item["id"] as? String else { continue }
            result[id] = (item["description"] as? String, item["coachingTip"] as? String)
        }
        return result
    }

    private func applyEnrichments(week: TrainingWeek, enrichments: [String: (String?, String?)]) -> TrainingWeek {
        var updated = week
        updated.workouts = week.workouts.map { workout in
            guard let (description, coachingTip) = enrichments[workout.id] else { return workout }
            var w = workout
            w.description = description
            w.coachingTip = coachingTip
            return w
        }
        return updated
    }
}
