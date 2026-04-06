import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/workout_exercise.dart';
import '../services/api_service.dart';

class AddWorkoutSessionScreen extends StatefulWidget {
  const AddWorkoutSessionScreen({super.key});

  @override
  State<AddWorkoutSessionScreen> createState() => _AddWorkoutSessionScreenState();
}

class _AddWorkoutSessionScreenState extends State<AddWorkoutSessionScreen> {
  final ApiService _apiService = ApiService();
  
  String _type = 'gym';
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  
  final List<WorkoutExercise> _exercises = [];
  bool _isSaving = false;

  void _navigateToAddExercise() async {
    final result = await context.push('/add-exercise');
    if (result != null && result is WorkoutExercise) {
      setState(() {
        _exercises.add(result);
      });
    }
  }

  void _saveSession() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one exercise.')));
      return;
    }

    setState(() => _isSaving = true);

    int? duration = int.tryParse(_durationCtrl.text.trim());
    if (duration != null) duration = duration * 60; // Convert typical user input (minutes) to seconds

    List<Map<String, dynamic>> exercisesPayload = _exercises.map((e) => e.toJson()).toList();

    bool success = await _apiService.createWorkoutSession(
      _type, 
      duration, 
      _notesCtrl.text.trim(), 
      exercisesPayload
    );

    setState(() => _isSaving = false);

    if (success) {
      if(mounted) context.pop(true); // Return home with a success flag
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save session. Try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workout Session'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Details Card
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(labelText: 'Workout Type'),
                      items: const [
                        DropdownMenuItem(value: 'gym', child: Text('Gym')),
                        DropdownMenuItem(value: 'run', child: Text('Run')),
                        DropdownMenuItem(value: 'swim', child: Text('Swim')),
                      ],
                      onChanged: (val) => setState(() => _type = val!),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _durationCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Duration (in minutes)', prefixIcon: Icon(Icons.timer_outlined)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notes', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Exercises List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Exercises', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _navigateToAddExercise,
                  icon: const Icon(Icons.add, color: Color(0xFF818CF8)),
                  label: const Text('Add Exercise', style: TextStyle(color: Color(0xFF818CF8))),
                )
              ],
            ),
            const SizedBox(height: 8),

            // Exercises List
            if (_exercises.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text("No exercises appended yet.", style: TextStyle(color: Colors.white54))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                itemBuilder: (context, i) {
                  final ex = _exercises[i];
                  return Card(
                    color: const Color(0xFF334155),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(ex.exerciseName ?? "Exercise #${ex.exerciseId}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${ex.sets} sets x ${ex.reps} reps${ex.weightKg != null ? ' @ ${ex.weightKg}kg' : ''}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => setState(() => _exercises.removeAt(i)),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
