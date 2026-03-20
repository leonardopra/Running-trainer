import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_plan.dart';
import 'storage_provider.dart';

/// ID del piano selezionato dall'utente. Null = usa l'ultimo piano creato.
final selectedPlanIdProvider = StateProvider<String?>((ref) => null);

/// Lista di tutti i piani salvati.
final allPlansProvider = Provider<List<TrainingPlan>>((ref) {
  // Re-evaluate when selection changes so consumers stay consistent.
  ref.watch(selectedPlanIdProvider);
  return ref.read(storageServiceProvider).getAllPlans();
});

/// Il piano attivo: quello selezionato dall'utente, oppure l'ultimo creato.
final activePlanProvider = Provider<TrainingPlan?>((ref) {
  final selectedId = ref.watch(selectedPlanIdProvider);
  final storage = ref.read(storageServiceProvider);

  if (selectedId != null) {
    final all = storage.getAllPlans();
    final found = all.where((p) => p.id == selectedId).firstOrNull;
    if (found != null) return found;
  }

  return storage.getActivePlan();
});
