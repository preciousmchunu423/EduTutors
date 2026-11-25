
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../viewmodels/auth_view_model.dart';
import '../widgets/common_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  static const Color _purple = Color(0xFF7652B5);
  static const Color _darkPurple = Color(0xFF4F347F);
  static const Color _lavender = Color(0xFFF0EBFA);
  static const Color _ink = Color(0xFF29243A);
  static const Color _muted = Color(0xFF858092);

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // ============================================================
  // REMEMBER ME
  // ============================================================

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString('remembered_email');
    final rememberMe = prefs.getBool('remember_me') ?? true;

    if (!mounted) return;

    setState(() {
      _rememberMe = rememberMe;

      if (rememberMe && savedEmail != null) {
        _email.text = savedEmail;
      }
    });
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      showAppSnack(
        context,
        'Please enter your email and password.',
        warning: true,
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      if (_rememberMe) {
        await prefs.setString(
          'remembered_email',
          _email.text.trim(),
        );
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('remembered_email');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      debugPrint('REMEMBER EMAIL ERROR: $e');
    }

    if (!mounted) return;

    final error = await context.read<AuthViewModel>().login(
          _email.text.trim(),
          _password.text,
        );

    if (!mounted) return;

    if (error != null) {
      showAppSnack(context, error, warning: true);
      return;
    }

    // The app root handles the correct dashboard.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> _showForgotPasswordDialog() async {
    final resetEmail = TextEditingController(text: _email.text.trim());

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool sending = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Forgot your password?',
                style: TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter the email address linked to your account. '
                    "We'll send you a password recovery link.",
                    style: TextStyle(
                      color: _muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: resetEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF8F6FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                TextButton(
                  onPressed: sending
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: _muted),
                  ),
                ),
                ElevatedButton(
                  onPressed: sending
                      ? null
                      : () async {
                          if (resetEmail.text.trim().isEmpty) {
                            showAppSnack(
                              this.context,
                              'Please enter your email address.',
                              warning: true,
                            );
                            return;
                          }

                          setDialogState(() => sending = true);

                          final error = await this.context
                              .read<AuthViewModel>()
                              .sendPasswordResetEmail(resetEmail.text);

                          if (!mounted) return;

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }

                          if (error != null) {
                            showAppSnack(
                              this.context,
                              error,
                              warning: true,
                            );
                          } else {
                            showAppSnack(
                              this.context,
                              'If an account exists for that email, '
                              'a password recovery link will be sent.',
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send link'),
                ),
              ],
            );
          },
        );
      },
    );

    resetEmail.dispose();
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFA7A2B1),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: _purple, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8F6FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFECE7F4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _purple,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  // ============================================================
  // WELCOME PANEL
  // ============================================================

  Widget _buildWelcomePanel({required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 25 : 38),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_darkPurple, _purple, Color(0xFF9B7BD0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'EDUTUTORS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 24 : 45),
          Text(
            'Learning is better when we grow together.',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 25 : 34,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Connect with tutors, explore learning resources, '
            'and make every study session count.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.7,
            ),
          ),
          SizedBox(height: compact ? 22 : 35),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Container(
                height: compact ? 105 : 150,
                width: compact ? 105 : 150,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: compact ? 55 : 75,
                  color: _purple,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          const _WelcomeFeature(
            icon: Icons.people_alt_outlined,
            text: 'Learn with experienced tutors',
          ),
          const SizedBox(height: 13),
          const _WelcomeFeature(
            icon: Icons.auto_stories_outlined,
            text: 'Access helpful study materials',
          ),
          const SizedBox(height: 13),
          const _WelcomeFeature(
            icon: Icons.trending_up_rounded,
            text: 'Track your learning progress',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGIN FORM
  // ============================================================

  Widget _buildLoginForm() {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _darkPurple.withValues(alpha: 0.07),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome back!',
            style: TextStyle(
              color: _ink,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Log in to continue your learning journey.',
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Email address',
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 9),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'Enter your email address',
              icon: Icons.email_outlined,
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Password',
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 9),
          TextField(
            controller: _password,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _login(),
            decoration: _inputDecoration(
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? 'Show password'
                    : 'Hide password',
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _muted,
                  size: 21,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // REMEMBER ME + FORGOT PASSWORD
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: _purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Remember me',
                style: TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: isLoading ? null : _showForgotPasswordDialog,
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: _purple,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _purple.withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 19),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: _muted,
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                child: const Text(
                  'Create account',
                  style: TextStyle(
                    color: _purple,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESPONSIVE LAYOUT
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 780;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildWelcomePanel(compact: false),
                            ),
                            const SizedBox(width: 35),
                            Expanded(
                              flex: 4,
                              child: _buildLoginForm(),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildWelcomePanel(compact: true),
                            const SizedBox(height: 22),
                            _buildLoginForm(),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================================================================
// WELCOME FEATURE
// ================================================================

class _WelcomeFeature extends StatelessWidget {
  const _WelcomeFeature({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
