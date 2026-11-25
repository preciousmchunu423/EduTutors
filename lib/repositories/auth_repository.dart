import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed authentication and profile repository.
/// Profile rows are created by the `on_edututors_user_created` database trigger.
class AuthRepository {
  AuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  Future<Map<String, dynamic>?> loadProfile(String userId) async {
    return _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  Future<bool> hasOrganizationAdminAccess(String userId) async {
    final rows = await _client
        .from('organization_memberships')
        .select('role')
        .eq('user_id', userId)
        .inFilter('role', ['owner', 'admin'])
        .limit(1);

    return (rows as List).isNotEmpty;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return _client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {
        'full_name': name.trim(),
        'role': role.trim().toLowerCase(),
      },
    );
  }

  /// Sends a password recovery email through Supabase Auth.
  Future<void> sendPasswordResetEmail({
    required String email,
  }) {
    return _client.auth.resetPasswordForEmail(
      email.trim().toLowerCase(),
    );
  }

  Future<void> saveLearnerGrade(
    String userId,
    String? grade,
  ) async {
    if (grade == null || grade.trim().isEmpty) return;

    await _client
        .from('learner_profiles')
        .update({'grade': grade.trim()})
        .eq('id', userId);
  }

  Future<void> signOut() => _client.auth.signOut();
}