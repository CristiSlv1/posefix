import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';

class AnalyzeSelectExerciseScreen extends StatefulWidget {
  const AnalyzeSelectExerciseScreen({super.key});

  @override
  State<AnalyzeSelectExerciseScreen> createState() => _AnalyzeSelectExerciseScreenState();
}

class _AnalyzeSelectExerciseScreenState extends State<AnalyzeSelectExerciseScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Exercise>> _future;
  Exercise? _selected;

  @override
  void initState() {
    super.initState();
    _future = _apiService.getExercises();
  }

  void _next() {
    final s = _selected;
    if (s == null) return;
    context.push('/analyze-video', extra: s);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('Analyze your posture')),
      body: FutureBuilder<List<Exercise>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: c.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load exercises:\n${snapshot.error}', textAlign: TextAlign.center),
            );
          }
          final exercises = snapshot.data ?? [];
          if (exercises.isEmpty) {
            return Center(child: Text('No exercises available.', style: TextStyle(color: c.textMuted)));
          }
          _selected ??= exercises.first;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  Card(
                    color: c.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<Exercise>(
                        value: _selected,
                        decoration: const InputDecoration(labelText: 'Exercise'),
                        isExpanded: true,
                        items: exercises
                            .map((e) => DropdownMenuItem<Exercise>(
                                  value: e,
                                  child: Text('${e.name} (${e.muscleGroup ?? 'General'})'),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selected = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      color: c.card,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: _ExerciseInfo(exercise: _selected!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: _selected == null ? null : _next,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExerciseInfo extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseInfo({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final description = exercise.description?.trim();
    final injury = exercise.injuryNotes?.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: c.textPrimary),
          ),
          if (exercise.muscleGroup != null) ...[
            const SizedBox(height: 4),
            Text(
              exercise.muscleGroup!,
              style: TextStyle(color: c.primaryLight, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold, color: c.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            description != null && description.isNotEmpty
                ? description
                : 'No description available yet for this exercise.',
            style: TextStyle(color: c.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          Text(
            'Common injuries & form notes',
            style: TextStyle(fontWeight: FontWeight.bold, color: c.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            injury != null && injury.isNotEmpty
                ? injury
                : 'No injury notes available yet. Upload a clean side-angle video with good lighting for best results.',
            style: TextStyle(color: c.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
