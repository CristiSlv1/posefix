import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';
import '../services/api_service.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final int workoutId;
  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final ApiService _apiService = ApiService();

  Workout? _workout;
  Map<int, Exercise> _exerciseCatalog = {};
  double? _weightKg;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    try {
      final results = await Future.wait([
        _apiService.getWorkout(widget.workoutId),
        _apiService.getExercises(),
        _apiService.getProfileWeightKg(),
      ]);
      if (!mounted) return;
      final workout = results[0] as Workout;
      final exercises = results[1] as List<Exercise>;
      final weightKg = results[2] as double?;
      final map = {for (final e in exercises) e.id: e};
      for (final we in workout.exercises) {
        we.exerciseName = map[we.exerciseId]?.name;
      }
      setState(() {
        _workout = workout;
        _exerciseCatalog = map;
        _weightKg = weightKg;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  double _estimateKcal() {
    final w = _workout;
    if (w == null || w.durationSeconds == null || w.durationSeconds! <= 0) return 0;
    final metByType = {'gym': 5.0, 'run': 9.8, 'swim': 8.0};
    final met = metByType[w.type.toLowerCase()] ?? 5.0;
    final weight = _weightKg ?? 70.0;
    return met * weight * (w.durationSeconds! / 3600.0);
  }

  Future<void> _editExercise(WorkoutExercise ex) async {
    final updated = await showDialog<WorkoutExercise>(
      context: context,
      builder: (_) => _EditExerciseDialog(exercise: ex),
    );
    if (updated == null || !mounted) return;
    final w = _workout;
    if (w == null) return;
    final index = w.exercises.indexWhere((e) => e.id == ex.id);
    if (index == -1) return;

    final original = w.exercises[index];
    setState(() => w.exercises[index] = updated);

    final ok = await _apiService.updateWorkoutExercise(w.id, ex.id!, updated);
    if (!mounted) return;
    if (!ok) {
      setState(() => w.exercises[index] = original);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update exercise')),
      );
    }
  }

  Future<void> _deleteExercise(WorkoutExercise ex) async {
    final c = context.appColors;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete exercise?'),
        content: Text('Remove ${ex.exerciseName ?? 'this exercise'} from the workout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text('Delete', style: TextStyle(color: c.danger)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final w = _workout;
    if (w == null) return;
    final index = w.exercises.indexWhere((e) => e.id == ex.id);
    if (index == -1) return;

    final removed = w.exercises[index];
    setState(() => w.exercises.removeAt(index));

    final ok = await _apiService.deleteWorkoutExercise(w.id, ex.id!);
    if (!mounted) return;
    if (!ok) {
      setState(() => w.exercises.insert(index, removed));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete exercise')),
      );
    }
  }

  Future<void> _addExercise() async {
    final result = await context.push('/add-exercise');
    if (result is! WorkoutExercise || !mounted) return;
    final w = _workout;
    if (w == null) return;

    final newId = await _apiService.addExerciseToWorkout(w.id, result);
    if (!mounted) return;
    if (newId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add exercise')),
      );
      return;
    }
    final withId = WorkoutExercise(
      id: newId,
      exerciseId: result.exerciseId,
      sets: result.sets,
      reps: result.reps,
      weightKg: result.weightKg,
      orderIndex: w.exercises.length,
      exerciseName: result.exerciseName ?? _exerciseCatalog[result.exerciseId]?.name,
    );
    setState(() => w.exercises.add(withId));
  }

  Future<void> _promptForWeight() async {
    final ctrl = TextEditingController();
    final weight = await showDialog<double>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Your weight'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Weight (kg)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.trim());
              if (v == null || v <= 0) {
                ScaffoldMessenger.of(dialogCtx).showSnackBar(
                  const SnackBar(content: Text('Enter a valid weight in kg.')),
                );
                return;
              }
              Navigator.pop(dialogCtx, v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (weight == null || !mounted) return;

    final previous = _weightKg;
    setState(() => _weightKg = weight);

    final ok = await _apiService.setProfileWeightKg(weight);
    if (!mounted) return;
    if (!ok) {
      setState(() => _weightKg = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save weight')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Details')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final c = context.appColors;
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }
    if (_error != null || _workout == null) {
      return Center(
        child: Text('Error: ${_error ?? 'unknown'}', textAlign: TextAlign.center),
      );
    }
    final w = _workout!;
    final kcal = _estimateKcal();
    final durationMin = w.durationSeconds != null ? (w.durationSeconds! ~/ 60) : null;

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: c.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    w.type.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: c.primaryLight, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    w.performedAt.substring(0, 10),
                    style: TextStyle(color: c.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          icon: Icons.timer_outlined,
                          label: 'Duration',
                          value: durationMin != null ? '$durationMin min' : '—',
                        ),
                      ),
                      Expanded(
                        child: _SummaryTile(
                          icon: Icons.local_fire_department_outlined,
                          label: 'Kcal (est.)',
                          value: kcal > 0 ? kcal.toStringAsFixed(0) : '—',
                        ),
                      ),
                    ],
                  ),
                  if (_weightKg == null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _promptForWeight,
                      icon: Icon(Icons.scale_outlined, color: c.primaryLight),
                      label: Text(
                        'Set your weight to estimate kcal',
                        style: TextStyle(color: c.primaryLight),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: c.primaryLight),
                        minimumSize: const Size.fromHeight(40),
                      ),
                    ),
                  ],
                  if (w.notes != null && w.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      w.notes!,
                      style: TextStyle(color: c.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Exercises', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _addExercise,
                icon: Icon(Icons.add, color: c.primaryLight),
                label: Text('Add', style: TextStyle(color: c.primaryLight)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (w.exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No exercises yet.', style: TextStyle(color: c.textMuted)),
              ),
            )
          else
            ...w.exercises.map((ex) => Card(
                  key: ValueKey(ex.id),
                  color: c.cardAlt,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      ex.exerciseName ?? 'Exercise #${ex.exerciseId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${ex.sets} sets x ${ex.reps} reps${ex.weightKg != null ? ' @ ${ex.weightKg}kg' : ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: c.primaryLight),
                          onPressed: () => _editExercise(ex),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: c.danger),
                          onPressed: () => _deleteExercise(ex),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      children: [
        Icon(icon, color: c.primaryLight),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: c.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _EditExerciseDialog extends StatefulWidget {
  final WorkoutExercise exercise;
  const _EditExerciseDialog({required this.exercise});

  @override
  State<_EditExerciseDialog> createState() => _EditExerciseDialogState();
}

class _EditExerciseDialogState extends State<_EditExerciseDialog> {
  late final TextEditingController _setsCtrl;
  late final TextEditingController _repsCtrl;
  late final TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    _setsCtrl = TextEditingController(text: widget.exercise.sets.toString());
    _repsCtrl = TextEditingController(text: widget.exercise.reps.toString());
    _weightCtrl = TextEditingController(
      text: widget.exercise.weightKg != null ? widget.exercise.weightKg.toString() : '',
    );
  }

  @override
  void dispose() {
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final sets = int.tryParse(_setsCtrl.text.trim()) ?? 0;
    final reps = int.tryParse(_repsCtrl.text.trim()) ?? 0;
    if (sets < 1 || reps < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sets and reps must be at least 1.')),
      );
      return;
    }
    final weight = double.tryParse(_weightCtrl.text.trim());
    Navigator.pop(
      context,
      WorkoutExercise(
        id: widget.exercise.id,
        exerciseId: widget.exercise.exerciseId,
        sets: sets,
        reps: reps,
        weightKg: weight,
        orderIndex: widget.exercise.orderIndex,
        exerciseName: widget.exercise.exerciseName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise.exerciseName ?? 'Edit exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(height: 12),
          TextField(
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Weight (kg, optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
