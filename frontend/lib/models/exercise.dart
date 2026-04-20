class Exercise {
  final int id;
  final String name;
  final String code;
  final String category;
  final String? muscleGroup;
  final String? description;
  final String? injuryNotes;

  Exercise({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    this.muscleGroup,
    this.description,
    this.injuryNotes,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      category: json['category'],
      muscleGroup: json['muscleGroup'],
      description: json['description'],
      injuryNotes: json['injuryNotes'],
    );
  }
}
