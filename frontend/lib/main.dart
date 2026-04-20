import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/workouts_screen.dart';
import 'screens/postures_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/add_workout_session_screen.dart';
import 'screens/add_exercise_screen.dart';
import 'screens/workout_detail_screen.dart';
import 'screens/analyze_select_exercise_screen.dart';
import 'screens/analyze_video_screen.dart';
import 'screens/posture_detail_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/personal_data_screen.dart';
import 'models/exercise.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  final themeService = ThemeService();
  await themeService.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider<ThemeService>.value(value: themeService),
      ],
      child: const PoseFixApp(),
    ),
  );
}

class PoseFixApp extends StatefulWidget {
  const PoseFixApp({super.key});

  @override
  State<PoseFixApp> createState() => _PoseFixAppState();
}

class _PoseFixAppState extends State<PoseFixApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Grab the auth service to feed into the router
    final authService = context.read<AuthService>();

    _router = GoRouter(
      initialLocation: '/home',
      // Re-evaluate the 'redirect' block anytime the authService calls notifyListeners()!
      refreshListenable: authService,
      redirect: (context, state) {
        final loggingIn = state.matchedLocation == '/login';
        final loggedIn = authService.isAuthenticated;

        // Force to login screen if not authenticated
        if (!loggedIn && !loggingIn) return '/login';
        
        // Force to home screen if user manually tries to go to login while already authenticated
        if (loggedIn && loggingIn) return '/home';
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/add-workout',
          builder: (context, state) => const AddWorkoutSessionScreen(),
        ),
        GoRoute(
          path: '/add-exercise',
          builder: (context, state) => const AddExerciseScreen(),
        ),
        GoRoute(
          path: '/analyze-select',
          builder: (context, state) => const AnalyzeSelectExerciseScreen(),
        ),
        GoRoute(
          path: '/analyze-video',
          builder: (context, state) => AnalyzeVideoScreen(
            exercise: state.extra as Exercise,
          ),
        ),
        GoRoute(
          path: '/settings/profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/settings/personal-data',
          builder: (context, state) => const PersonalDataScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavigationScreen(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/workouts',
                  builder: (context, state) => const WorkoutsScreen(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => WorkoutDetailScreen(
                        workoutId: int.parse(state.pathParameters['id']!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/postures',
                  builder: (context, state) => const PosturesScreen(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => PostureDetailScreen(
                        analysisId: int.parse(state.pathParameters['id']!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    return MaterialApp.router(
      title: 'PoseFix AI',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: lightAppTheme,
      darkTheme: darkAppTheme,
      themeMode: themeService.mode,
    );
  }
}
