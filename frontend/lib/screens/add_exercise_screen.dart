import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/exercise.dart';
import '../models/workout_exercise.dart';
import '../services/api_service.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Exercise>> _exercisesFuture;

  Exercise? _selectedExercise;
  final TextEditingController _setsCtrl = TextEditingController(text: "3");
  final TextEditingController _repsCtrl = TextEditingController(text: "10");
  final TextEditingController _weightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _apiService.getExercises();
  }

  void _saveExerciseToSession() {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an exercise.')));
      return;
    }

    final sets = int.tryParse(_setsCtrl.text.trim()) ?? 0;
    final reps = int.tryParse(_repsCtrl.text.trim()) ?? 0;
    if (sets == 0 || reps == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sets and Reps must be valid numbers.')));
      return;
    }

    final weight = double.tryParse(_weightCtrl.text.trim());

    final workoutExercise = WorkoutExercise(
      exerciseId: _selectedExercise!.id,
      sets: sets,
      reps: reps,
      weightKg: weight,
      exerciseName: _selectedExercise!.name,
    );

    // Pop and return the object back to the Session Form
    context.pop(workoutExercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an Exercise'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          } else if (snapshot.hasError) {
             return Center(child: Text("Failed to load global exercises\n${snapshot.error}", textAlign: TextAlign.center));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return const Center(child: Text("No exercises found in DB."));
          }

          final exercises = snapshot.data!;
          // Default selection if none picked
          if (_selectedExercise == null && exercises.isNotEmpty) {
             _selectedExercise = exercises.first;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<Exercise>(
                      value: _selectedExercise,
                      decoration: const InputDecoration(labelText: 'Physical Exercise'),
                      items: exercises.map((e) {
                        return DropdownMenuItem<Exercise>(
                          value: e,
                          child: Text("${e.name} (${e.muscleGroup ?? 'General'})"),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedExercise = val),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _setsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Sets'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _repsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Reps'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Weight (kg, optional)'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveExerciseToSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Confirm Exercise'),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      )
    );
  }
}
