class WorkoutExercise {
  final int? id; // Nullable because when creating locally, there's no ID yet
  final int exerciseId;
  final int sets;
  final int reps;
  final double? weightKg;
  final int orderIndex;
  
  // Transient property used purely for UI display during creation
  String? exerciseName; 

  WorkoutExercise({
    this.id,
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.orderIndex = 0,
    this.exerciseName,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'],
      exerciseId: json['exerciseId'],
      sets: json['sets'],
      reps: json['reps'],
      weightKg: json['weightKg'] != null ? (json['weightKg'] as num).toDouble() : null,
      orderIndex: json['orderIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      // API accepts weightKg, even if null it ignores or places null
      if (weightKg != null) 'weightKg': weightKg,
    };
  }
}
