class Profile {
  final String name;
  final String? birthDate;
  final double? weightKg;
  final int? heightCm;
  final String? sex;

  Profile({
    required this.name,
    this.birthDate,
    this.weightKg,
    this.heightCm,
    this.sex,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    final w = json['weightKg'];
    return Profile(
      name: (json['name'] as String?) ?? '',
      birthDate: json['birthDate']?.toString(),
      weightKg: w == null ? null : (w as num).toDouble(),
      heightCm: (json['heightCm'] as num?)?.toInt(),
      sex: json['sex'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (birthDate != null) 'birthDate': birthDate,
      if (weightKg != null) 'weightKg': weightKg,
      if (heightCm != null) 'heightCm': heightCm,
      if (sex != null) 'sex': sex,
    };
  }

  Profile copyWith({
    String? name,
    String? birthDate,
    double? weightKg,
    int? heightCm,
    String? sex,
  }) {
    return Profile(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      sex: sex ?? this.sex,
    );
  }
}
