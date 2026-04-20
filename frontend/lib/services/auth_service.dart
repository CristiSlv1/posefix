import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthService manages the user's authentication state across the entire app.
/// By extending ChangeNotifier, the UI can listen and automatically update 
/// whenever the user logs in or logs out!
class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Real-time access to the current state
  bool get isAuthenticated => _supabase.auth.currentSession != null;
  User? get currentUser => _supabase.auth.currentUser;
  
  // This is the Magic Token we will send to Spring Boot Web API!
  String? get currentToken => _supabase.auth.currentSession?.accessToken;

  AuthService() {
    // Listen to changes in auth state from Supabase servers
    _supabase.auth.onAuthStateChange.listen((data) {
      // Whenever a login, logout, or automatic token refresh happens, 
      // trigger notifyListeners() to immediately update any Flutter screen watching this Provider!
      notifyListeners();
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
