import '../main.dart';

class AuthService {
  Future<void> login(String email, String password) async {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
