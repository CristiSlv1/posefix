import 'package:flutter/foundation.dart';

class WeightEntry {
  final int id;
  final double weightKg;
  final DateTime measuredOn;
  final String? source;

  WeightEntry({
    required this.id,
    required this.weightKg,
    required this.measuredOn,
    this.source,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: (json['id'] as num).toInt(),
      weightKg: (json['weightKg'] as num).toDouble(),
      measuredOn: DateTime.parse(json['measuredOn'].toString()),
      source: json['source'] as String?,
    );
  }
}

final ValueNotifier<int> weightHistoryVersion = ValueNotifier<int>(0);
