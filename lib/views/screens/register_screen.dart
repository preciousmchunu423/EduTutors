import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/common_widgets.dart';
import '../widgets/custom_button.dart';
import '../widgets/grade_subject_picker.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _role = 'Parent';
  String _grade = 'Grade 10';
  List<String> _subjects = ['Mathematics'];
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _parentEmail = TextEditingController();
  bool _agree = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _parentEmail.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.isEmpty) {
      showAppSnack(context, 'Please fill in all fields.', warning: true);
      return;
    }
    if (_password.text != _confirm.text) {
      showAppSnack(context, 'Passwords do not match.', warning: true);
      return;
    }
    if (!_agree) {
      showAppSnack(context, 'Please accept the terms and conditions.', warning: true);
      return;
    }

    final error = await context.read<AuthViewModel>().register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          role: _role,
          parentEmail: _parentEmail.text,
          grade: _grade,
          subjects: _subjects,
        );
    if (!mounted) return;

    if (error != null) {
      showAppSnack(context, error, warning: true);
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AuthHeader(
            title: 'Join EduTutors',
            subtitle: 'Parents, learners and tutors all start here',
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'Parent', label: Text('Parent')),
                      ButtonSegment(value: 'Learner', label: Text('Learner')),
                      ButtonSegment(value: 'Tutor', label: Text('Tutor')),
                    ],
                    selected: {_role},
                    onSelectionChanged: (s) => setState(() => _role = s.first),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.selected)
                            ? AppColors.blue
                            : AppColors.white,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.selected)
                            ? AppColors.white
                            : AppColors.blue,
                      ),
                      side: const WidgetStatePropertyAll(
                        BorderSide(color: AppColors.blueLine),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_role == 'Tutor')
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.yellowSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.yellow.withOpacity(.45)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.verified_user_outlined, color: AppColors.navy),
                          SizedBox(width: 10),
                          Expanded(child: Text(
                            'Tutor verification is required. After creating your account, you will upload your qualification documents. An organisation admin must review and approve them before you can teach.',
                            style: TextStyle(color: AppColors.navy, fontSize: 12, height: 1.4),
                          )),
                        ],
                      ),
                    ),
                  if (_role == 'Learner')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(12)),
                      child: const Text(
                        'Parent linking is completed securely after registration when the parent accepts a link request.',
                        style: TextStyle(color: AppColors.navy, fontSize: 12, height: 1.4),
                      ),
                    ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _name,
                    label: 'Full name',
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _password,
                    label: 'Password (8 characters or more)',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _confirm,
                    label: 'Confirm password',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),
                  if (_role == 'Learner') ...[
                    const SizedBox(height: 14),
                    GradeSubjectPicker(
                      grade: _grade,
                      subjects: _subjects,
                      onChanged: (g, subs) => setState(() {
                        _grade = g;
                        _subjects = subs;
                      }),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _parentEmail,
                      label: "Parent's email (optional)",
                      icon: Icons.family_restroom_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'Link to a parent account so they can follow your progress.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _agree,
                        onChanged: (v) => setState(() => _agree = v ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'I agree to the Terms and Conditions',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Create account',
                    onPressed: _register,
                    loading: context.watch<AuthViewModel>().isLoading,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: const Text(
                          'Log in',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
            ),
          ),
        ],
      ),
    );
  }
}
