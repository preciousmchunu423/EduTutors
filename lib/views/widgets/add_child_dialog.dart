
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'common_widgets.dart';
import '../../models/user_account.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'custom_button.dart';
import 'grade_subject_picker.dart';

/// Lets a parent add a child with a grade and subjects.
/// Returns true if a child was added.
Future<bool> showAddChildDialog(BuildContext context) async {
  final added = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => const _AddChildScreen(),
      fullscreenDialog: true,
    ),
  );

  return added ?? false;
}

class _AddChildScreen extends StatefulWidget {
  const _AddChildScreen();

  @override
  State<_AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<_AddChildScreen> {
  final _name = TextEditingController();

  String _grade = 'Grade 3';
  List<String> _subjects = ['Mathematics'];
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      showAppSnack(
        context,
        "Enter your child's name.",
        warning: true,
      );
      return;
    }

    if (_subjects.isEmpty) {
      showAppSnack(
        context,
        'Choose at least one subject.',
        warning: true,
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await context.read<AuthViewModel>().addChild(
        _name.text.trim(),
        _grade,
        _subjects,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() => _saving = false);

      showAppSnack(
        context,
        'Could not add child. Please try again.',
        warning: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FC),
      appBar: AppBar(
        title: const Text('Add a child'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: "Child's name",
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 20),
            GradeSubjectPicker(
              grade: _grade,
              subjects: _subjects,
              onChanged: (grade, subjects) {
                setState(() {
                  _grade = grade;
                  _subjects = subjects;
                });
              },
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Save child',
              onPressed: _save,
              loading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}
