import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class ApiService {
  final String baseUrl = AppConstants.springBootBaseUrl;
  
  Future<String?> _getToken() async {
    return Supabase.instance.client.auth.currentSession?.accessToken;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- EXERCISES ---

  Future<List<Exercise>> getExercises() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Exercise.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  // --- WORKOUTS ---

  Future<List<Workout>> getWorkouts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/workouts'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Workout.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load workouts');
    }
  }

  Future<bool> createWorkoutSession(String type, int? durationSeconds, String? notes, List<Map<String, dynamic>> exercises) async {
    final Map<String, dynamic> body = {
      'type': type,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'exercises': exercises,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/workouts'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Failed to create workout: ${response.body}');
      return false;
    }
  }
}
