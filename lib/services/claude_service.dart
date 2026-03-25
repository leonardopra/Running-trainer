import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/training_week.dart';
import '../models/workout.dart';

class ClaudeService {
  static const _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-6';
  static const _maxRetries = 3;

  final Dio _dio;

  ClaudeService() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  Future<TrainingWeek> enrichWeek({
    required TrainingWeek week,
    required String apiKey,
    required String goalType,
    required String fitnessLevel,
    int? age,
    double? weightKg,
    double? heightCm,
  }) async {
    final workoutsJson = week.workouts
        .where((w) => w.type.name != 'rest')
        .map((w) => w.toJson())
        .toList();

    String profileContext = '';
    if (age != null) {
      final maxHr = 220 - age;
      profileContext = '\nRunner profile: age $age'
          '${weightKg != null ? ', ${weightKg.toStringAsFixed(0)}kg' : ''}'
          '${heightCm != null ? ', ${heightCm.toStringAsFixed(0)}cm' : ''}.'
          '\nMax HR ≈ $maxHr bpm. Include age-appropriate recovery cues and HR zone guidance.';
    }

    final prompt = '''Week ${week.weekNumber}: ${week.weekTheme}
Target: ${week.targetWeeklyKm}km
Goal: $goalType | Level: $fitnessLevel$profileContext

Workouts to enrich:
${jsonEncode(workoutsJson)}

Return ONLY a JSON array with this structure for each workout:
[{"id": "...", "description": "...", "coachingTip": "..."}]

Rules: max 60 words per description, direct/practical tone, no markdown.''';

    final response = await _callWithRetry(
      apiKey: apiKey,
      prompt: prompt,
    );

    final enrichments = _parseEnrichments(response);
    return _applyEnrichments(week, enrichments);
  }

  Future<String?> generatePostWorkoutCoaching({
    required Workout workout,
    required String apiKey,
    int? rpe,
    WorkoutFeeling? feeling,
    double? actualDistanceKm,
    int? actualDurationMinutes,
    String? notes,
    int? age,
  }) async {
    final distStr = actualDistanceKm != null
        ? '${actualDistanceKm.toStringAsFixed(2)} km'
        : 'unknown distance';
    final durStr = actualDurationMinutes != null
        ? '$actualDurationMinutes min'
        : 'unknown duration';
    final rpeStr = rpe != null ? '$rpe/10' : 'not logged';
    final feelingStr = feeling != null ? feeling.name : 'not logged';
    final notesStr = (notes != null && notes.isNotEmpty) ? notes : 'none';
    final ageStr = age != null ? ', age $age' : '';

    final typeLabel = workout.type.name
        .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ');
    final prompt =
        'Athlete$ageStr completed a $typeLabel '
        '(planned: ${workout.distanceKm?.toStringAsFixed(1) ?? '?'} km). '
        'Actual: $distStr, $durStr. RPE: $rpeStr. Feeling: $feelingStr. Notes: $notesStr. '
        'Give 2-3 sentences of honest, practical coaching feedback. Be concise, no markdown.';

    try {
      final text = await _callWithRetry(
        apiKey: apiKey,
        prompt: prompt,
        systemPrompt:
            'You are an experienced running coach. Give concise, honest, actionable post-workout feedback. Plain text only, no markdown, max 80 words.',
        maxTokens: 256,
      );
      return text.trim();
    } catch (_) {
      return null;
    }
  }

  Future<String> _callWithRetry({
    required String apiKey,
    required String prompt,
    String? systemPrompt,
    int maxTokens = 1024,
    int attempt = 0,
  }) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        }),
        data: {
          'model': _model,
          'max_tokens': maxTokens,
          'system': systemPrompt ??
              'You are an expert running coach. Provide concise, practical workout guidance. Always respond with valid JSON only — no markdown, no code fences.',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        },
      );

      final content = response.data['content'] as List;
      final text = content.first['text'] as String;
      return text;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ClaudeApiException('Invalid API key. Check your key in Settings.', isAuthError: true);
      }
      if (e.response?.statusCode == 429 && attempt < _maxRetries) {
        final delay = Duration(seconds: (2 * (attempt + 1)));
        await Future.delayed(delay);
        return _callWithRetry(
          apiKey: apiKey,
          prompt: prompt,
          systemPrompt: systemPrompt,
          maxTokens: maxTokens,
          attempt: attempt + 1,
        );
      }
      throw ClaudeApiException('Failed to connect to Claude API: ${e.message}');
    }
  }

  List<Map<String, dynamic>> _parseEnrichments(String response) {
    var cleaned = response.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceAll(RegExp(r'```[a-z]*\n?'), '').trim();
    }

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  TrainingWeek _applyEnrichments(TrainingWeek week, List<Map<String, dynamic>> enrichments) {
    final enrichmentMap = <String, Map<String, dynamic>>{};
    for (final e in enrichments) {
      enrichmentMap[e['id'] as String] = e;
    }

    final updatedWorkouts = week.workouts.map((workout) {
      final enrichment = enrichmentMap[workout.id];
      if (enrichment != null) {
        workout.description = enrichment['description'] as String?;
        workout.coachingTip = enrichment['coachingTip'] as String?;
      }
      return workout;
    }).toList();

    week.workouts = updatedWorkouts;
    return week;
  }
}

class ClaudeApiException implements Exception {
  final String message;
  final bool isAuthError;

  ClaudeApiException(this.message, {this.isAuthError = false});

  @override
  String toString() => 'ClaudeApiException: $message';
}
