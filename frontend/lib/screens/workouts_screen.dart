import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/workout.dart';
import '../services/api_service.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  late Future<List<Workout>> _workoutsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _refreshWorkouts();
  }

  void _refreshWorkouts() {
    setState(() {
      _workoutsFuture = _apiService.getWorkouts();
    });
  }

  void _navigateToAddWorkout(BuildContext context) async {
    final result = await context.push('/add-workout');
    // If we receive a true response, refresh the history feed immediately!
    if (result == true) {
      _refreshWorkouts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Workout>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error fetching workouts:\n${snapshot.error}", 
                textAlign: TextAlign.center, 
                style: const TextStyle(color: Colors.redAccent)
              )
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center_rounded, size: 80, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    "no workouts yet, add a new session",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddWorkout(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Add a new session"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  )
                ],
              ),
            );
          }

          final workouts = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshWorkouts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final w = workouts[index];
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              w.type.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF818CF8), fontSize: 16),
                            ),
                            Text(
                              w.performedAt.substring(0, 10), // Extract YYYY-MM-DD
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                        if (w.durationSeconds != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            "⏱️ Duration: ${w.durationSeconds! ~/ 60} min",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                        if (w.notes != null && w.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "📝 ${w.notes}",
                            style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          "${w.exercises.length} Exercises Logged",
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddWorkout(context),
        backgroundColor: const Color(0xFF6366F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
