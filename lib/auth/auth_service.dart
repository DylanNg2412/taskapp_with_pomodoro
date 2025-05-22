import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<AuthResponse> logInWithEmailPassword(String email, String pass) async {
    return await supabase.auth.signInWithPassword(email: email, password: pass);
  }

  Future<AuthResponse> signUpWithEmailPassword(String email, String pass) async {
    return await supabase.auth.signUp(email: email, password: pass);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

//To Show User Details
  String? getCurrentUserEmail() {
    final session = supabase.auth.currentSession;
    return session?.user.email;
  }
}