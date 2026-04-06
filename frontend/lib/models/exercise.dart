class Exercise {
  final int id;
  final String name;
  final String code;
  final String category;
  final String? muscleGroup;
  final String? description;

  Exercise({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    this.muscleGroup,
    this.description,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      category: json['category'],
      muscleGroup: json['muscleGroup'],
      description: json['description'],
    );
  }
}
