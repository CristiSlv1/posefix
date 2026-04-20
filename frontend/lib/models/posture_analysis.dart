import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Bumped whenever a new posture analysis is created so list screens
/// know to re-fetch even when they were not unmounted.
final ValueNotifier<int> postureListVersion = ValueNotifier<int>(0);

class PostureMistake {
  final String mistake;
  final String? severity;

  PostureMistake({required this.mistake, this.severity});

  factory PostureMistake.fromJson(Map<String, dynamic> json) {
    return PostureMistake(
      mistake: json['mistake']?.toString() ?? '',
      severity: json['severity']?.toString(),
    );
  }
}

class PostureAnalysis {
  final int id;
  final int? exerciseId;
  final String? exerciseName;
  final int score;
  final int mistakeCount;
  final int framesAnalyzed;
  final List<PostureMistake> mistakes;
  final Map<String, dynamic> anglesSummary;
  final String? createdAt;

  PostureAnalysis({
    required this.id,
    this.exerciseId,
    this.exerciseName,
    required this.score,
    required this.mistakeCount,
    required this.framesAnalyzed,
    required this.mistakes,
    required this.anglesSummary,
    this.createdAt,
  });

  factory PostureAnalysis.fromJson(Map<String, dynamic> json) {
    final rawMistakes = json['mistakes'];
    List<PostureMistake> parsedMistakes = const [];
    if (rawMistakes is String && rawMistakes.isNotEmpty) {
      final decoded = jsonDecode(rawMistakes);
      if (decoded is List) {
        parsedMistakes = decoded
            .whereType<Map>()
            .map((m) => PostureMistake.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
    } else if (rawMistakes is List) {
      parsedMistakes = rawMistakes
          .whereType<Map>()
          .map((m) => PostureMistake.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    final rawAngles = json['anglesSummary'];
    Map<String, dynamic> anglesMap = {};
    if (rawAngles is String && rawAngles.isNotEmpty) {
      final decoded = jsonDecode(rawAngles);
      if (decoded is Map) anglesMap = Map<String, dynamic>.from(decoded);
    } else if (rawAngles is Map) {
      anglesMap = Map<String, dynamic>.from(rawAngles);
    }

    return PostureAnalysis(
      id: json['id'] as int,
      exerciseId: json['exerciseId'] is int
          ? json['exerciseId']
          : (json['exerciseId'] as num?)?.toInt(),
      exerciseName: json['exerciseName'] as String?,
      score: (json['score'] as num?)?.toInt() ?? 0,
      mistakeCount: (json['mistakeCount'] as num?)?.toInt() ?? 0,
      framesAnalyzed: (json['framesAnalyzed'] as num?)?.toInt() ?? 0,
      mistakes: parsedMistakes,
      anglesSummary: anglesMap,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
