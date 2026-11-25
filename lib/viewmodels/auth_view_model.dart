import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_account.dart';
import '../repositories/auth_repository.dart';

/// Authentication state is driven by Supabase Auth, never local password storage.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository) {
    _subscription = _repository.authChanges.listen((state) {
      _refreshFromUser(state.session?.user ?? _repository.currentUser);
    });

    _refreshFromUser(_repository.currentUser);
  }

  final AuthRepository _repository;

  StreamSubscription<AuthState>? _subscription;

  User? _authUser;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _learnerProfile;

  bool _ready = false;
  bool _isLoading = false;
  bool _isOrgAdmin = false;

  bool get isReady => _ready;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _authUser != null;
  bool get isOrgAdmin => _isOrgAdmin;

  String? get userId => _authUser?.id;

  String? get userName {
    final value =
        _profile?['full_name'] ?? _authUser?.userMetadata?['full_name'];

    return value?.toString();
  }

  String? get userEmail => _authUser?.email;

  String? get userRole {
    final role = (_profile?['role'] as String? ?? '').toLowerCase();

    switch (role) {
      case 'learner':
        return 'Learner';
      case 'tutor':
        return 'Tutor';
      case 'parent':
        return 'Parent';
      default:
        return null;
    }
  }

  String? get userGrade => _learnerProfile?['grade'] as String?;

  List<String> get userSubjects => const [];

  /// Parent-child linking uses the secure invitation workflow.
  List<Child> get children => const [];

  static final RegExp _emailPattern =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<void> _refreshFromUser(User? user) async {
    _authUser = user;
    _profile = null;
    _learnerProfile = null;
    _isOrgAdmin = false;

    if (user != null) {
      try {
        debugPrint('EduTutors: Loading profile for ${user.id}');

        _profile = await _repository.loadProfile(user.id);

        if (_profile == null) {
          debugPrint(
            'PROFILE LOADING ERROR: No profile row returned for user ${user.id}',
          );
        } else {
          debugPrint(
            'EduTutors: Profile loaded. Role: ${_profile?['role']}',
          );
        }

        if (userRole == 'Learner') {
          _learnerProfile = await Supabase.instance.client
              .from('learner_profiles')
              .select('grade')
              .eq('id', user.id)
              .maybeSingle();
        }

        _isOrgAdmin =
            await _repository.hasOrganizationAdminAccess(user.id);
      } catch (error, stackTrace) {
        debugPrint('PROFILE LOADING ERROR: $error');
        debugPrint('PROFILE STACK TRACE: $stackTrace');
      }
    }

    _ready = true;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    if (!_emailPattern.hasMatch(email.trim())) {
      return 'Please enter a valid email address.';
    }

    if (password.isEmpty) {
      return 'Please enter your password.';
    }

    _setLoading(true);

    try {
      final response = await _repository.signIn(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return 'We could not sign you in. Please try again.';
      }

      await _refreshFromUser(response.user);

      if (_profile == null) {
        await _repository.signOut();
        await _refreshFromUser(null);

        return 'Your profile could not be loaded. Please try again or contact support.';
      }

      if (userRole == null) {
        await _repository.signOut();
        await _refreshFromUser(null);

        return 'Your account has an invalid role. Please contact support.';
      }

      return null;
    } on AuthException catch (e) {
      debugPrint('EduTutors login authentication error: ${e.message}');
      return _friendlyAuthError(e.message);
    } catch (e, stackTrace) {
      debugPrint('EduTutors login error: $e');
      debugPrint('EduTutors login stack trace: $stackTrace');

      return 'Unable to log in right now. Please check your connection and try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Requests a password recovery email.
  Future<String?> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!_emailPattern.hasMatch(normalizedEmail)) {
      return 'Please enter a valid email address.';
    }

    _setLoading(true);

    try {
      await _repository.sendPasswordResetEmail(
        email: normalizedEmail,
      );

      return null;
    } on AuthException catch (e) {
      debugPrint('EduTutors password reset error: ${e.message}');
      return _friendlyAuthError(e.message);
    } catch (e, stackTrace) {
      debugPrint('EduTutors password reset error: $e');
      debugPrint('EduTutors password reset stack trace: $stackTrace');

      return 'We could not send the recovery email. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? parentEmail,
    String? grade,
    List<String>? subjects,
  }) async {
    final normalizedRole = role.trim().toLowerCase();
    final normalizedEmail = email.trim().toLowerCase();

    if (name.trim().isEmpty) {
      return 'Please enter your full name.';
    }

    if (!_emailPattern.hasMatch(normalizedEmail)) {
      return 'Please enter a valid email address.';
    }

    if (password.length < 8) {
      return 'Use a password with at least 8 characters.';
    }

    if (!['learner', 'tutor', 'parent'].contains(normalizedRole)) {
      return 'Please select a valid account type.';
    }

    _setLoading(true);

    try {
      final response = await _repository.signUp(
        name: name,
        email: normalizedEmail,
        password: password,
        role: normalizedRole,
      );

      final user = response.user;

      if (user == null) {
        return 'Account creation could not be completed. Please try again.';
      }

      if (response.session == null) {
        return 'Your account was created. Please verify your email, then log in.';
      }

      if (normalizedRole == 'learner') {
        await _repository.saveLearnerGrade(user.id, grade);
      }

      await _refreshFromUser(user);

      if (_profile == null) {
        return 'Your account was created, but its profile could not be loaded. Please try logging in again.';
      }

      return null;
    } on AuthException catch (e) {
      debugPrint('EduTutors registration authentication error: ${e.message}');
      return _friendlyAuthError(e.message);
    } catch (e, stackTrace) {
      debugPrint('EduTutors registration error: $e');
      debugPrint('EduTutors registration stack trace: $stackTrace');

      return 'We could not complete registration. Please check your connection and try again.';
    } finally {
      _setLoading(false);
    }
  }

  String _friendlyAuthError(String message) {
    final m = message.toLowerCase();

    if (m.contains('already registered') ||
        m.contains('already exists')) {
      return 'An account with this email already exists. Please log in.';
    }

    if (m.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }

    if (m.contains('email not confirmed')) {
      return 'Please confirm your email before logging in.';
    }

    if (m.contains('password')) {
      return message;
    }

    return message;
  }

  @Deprecated(
    'Use the parent-child invitation workflow; do not create local children.',
  )
  Future<void> addChild(
    String name,
    String grade,
    List<String> subjects,
  ) async {}

  @Deprecated(
    'Parent-child links are managed through accepted invitations.',
  )
  Future<void> removeChild(String id) async {}

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _repository.signOut();
      await _refreshFromUser(null);
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}