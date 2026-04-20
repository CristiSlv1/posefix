import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../models/exercise.dart';
import '../models/posture_analysis.dart';
import '../models/profile.dart';
import '../models/weight_entry.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';

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

  Future<Workout> getWorkout(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/workouts/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return Workout.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load workout: ${response.body}');
  }

  Future<int?> addExerciseToWorkout(int workoutId, WorkoutExercise ex) async {
    final response = await http.post(
      Uri.parse('$baseUrl/workouts/$workoutId/exercises'),
      headers: await _getHeaders(),
      body: jsonEncode(ex.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      final id = body['id'];
      return id is int ? id : (id as num?)?.toInt();
    }
    return null;
  }

  Future<bool> updateWorkoutExercise(int workoutId, int exId, WorkoutExercise ex) async {
    final response = await http.put(
      Uri.parse('$baseUrl/workouts/$workoutId/exercises/$exId'),
      headers: await _getHeaders(),
      body: jsonEncode(ex.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteWorkoutExercise(int workoutId, int exId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/workouts/$workoutId/exercises/$exId'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // --- POSTURES ---

  Future<List<PostureAnalysis>> getPostures() async {
    final response = await http.get(
      Uri.parse('$baseUrl/postures'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => PostureAnalysis.fromJson(j)).toList();
    }
    throw Exception('Failed to load postures: ${response.body}');
  }

  Future<PostureAnalysis> getPosture(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/postures/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return PostureAnalysis.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load posture: ${response.body}');
  }

  Future<PostureAnalysis> analyzePosture(int exerciseId, String videoPath) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/postures/analyze');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields['exerciseId'] = exerciseId.toString();
    request.files.add(await http.MultipartFile.fromPath('file', videoPath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return PostureAnalysis.fromJson(jsonDecode(response.body));
    }
    throw Exception('Analysis failed (${response.statusCode}): ${response.body}');
  }

  // --- PROFILE ---

  Future<Profile?> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return Profile.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 404) return null;
    throw Exception('Failed to load profile: ${response.body}');
  }

  Future<bool> updateProfile(Profile profile) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: await _getHeaders(),
      body: jsonEncode(profile.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<double?> getProfileWeightKg() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final w = body['weightKg'];
      return w == null ? null : (w as num).toDouble();
    }
    return null;
  }

  Future<bool> logWeightToday(double weightKg) async {
    final response = await http.put(
      Uri.parse('$baseUrl/weights/today'),
      headers: await _getHeaders(),
      body: jsonEncode({'weightKg': weightKg}),
    );
    return response.statusCode == 200;
  }

  Future<List<WeightEntry>> getWeightHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/weights'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => WeightEntry.fromJson(j)).toList();
    }
    throw Exception('Failed to load weight history: ${response.body}');
  }

  Future<bool> setProfileWeightKg(double weightKg) async {
    final headers = await _getHeaders();

    final getResp = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: headers,
    );

    Map<String, dynamic> body;
    if (getResp.statusCode == 200) {
      final current = jsonDecode(getResp.body) as Map<String, dynamic>;
      body = {
        'name': (current['name'] is String && (current['name'] as String).isNotEmpty)
            ? current['name']
            : 'User',
        if (current['birthDate'] != null) 'birthDate': current['birthDate'],
        'weightKg': weightKg,
        if (current['heightCm'] != null) 'heightCm': current['heightCm'],
        if (current['sex'] != null) 'sex': current['sex'],
      };
    } else if (getResp.statusCode == 404) {
      body = {'name': 'User', 'weightKg': weightKg};
    } else {
      return false;
    }

    final putResp = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: headers,
      body: jsonEncode(body),
    );
    return putResp.statusCode == 200;
  }
}
