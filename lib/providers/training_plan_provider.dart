import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_plan.dart';
import 'storage_provider.dart';

final activePlanProvider = Provider<TrainingPlan?>((ref) {
  return ref.read(storageServiceProvider).getActivePlan();
});
