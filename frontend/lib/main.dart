import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';

import 'core/constants.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
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
      initialLocation: '/',
      // Re-evaluate the 'redirect' block anytime the authService calls notifyListeners()!
      refreshListenable: authService,
      redirect: (context, state) {
        final loggingIn = state.matchedLocation == '/login';
        final loggedIn = authService.isAuthenticated;

        // Force to login screen if not authenticated
        if (!loggedIn && !loggingIn) return '/login';
        
        // Force to home screen if user manually tries to go to login while already authenticated
        if (loggedIn && loggingIn) return '/';
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const AuthScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PoseFix AI',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
      ),
    );
  }
}
