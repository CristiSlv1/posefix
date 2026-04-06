import 'workout_exercise.dart';

class Workout {
  final int id;
  final String userId;
  final String type;
  final String performedAt;
  final int? durationSeconds;
  final String? notes;
  final String createdAt;
  final List<WorkoutExercise> exercises;

  Workout({
    required this.id,
    required this.userId,
    required this.type,
    required this.performedAt,
    this.durationSeconds,
    this.notes,
    required this.createdAt,
    required this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    var exercisesList = json['exercises'] as List? ?? [];
    List<WorkoutExercise> exercises = exercisesList.map((e) => WorkoutExercise.fromJson(e)).toList();

    return Workout(
      id: json['id'],
      userId: json['userId'],
      type: json['type'] ?? 'gym',
      performedAt: json['performedAt'],
      durationSeconds: json['durationSeconds'],
      notes: json['notes'],
      createdAt: json['createdAt'],
      exercises: exercises,
    );
  }
}
