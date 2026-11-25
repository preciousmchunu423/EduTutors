import 'package:flutter/material.dart';

import '../../data/tutors_data.dart';
import '../../theme/app_theme.dart';

/// Grade chips (primary and high school) plus subject chips that follow the
/// chosen grade. Used when registering a learner and when adding a child.
class GradeSubjectPicker extends StatelessWidget {
  const GradeSubjectPicker({
    super.key,
    required this.grade,
    required this.subjects,
    required this.onChanged,
  });

  final String grade;
  final List<String> subjects;
  final void Function(String grade, List<String> subjects) onChanged;

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppColors.blue,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => onTap(),
    );
  }

  void _pickGrade(String g) {
    final allowed = subjectsForGrade(g);
    onChanged(g, subjects.where(allowed.contains).toList());
  }

  void _toggleSubject(String s) {
    final next = [...subjects];
    next.contains(s) ? next.remove(s) : next.add(s);
    onChanged(grade, next);
  }

  @override
  Widget build(BuildContext context) {
    final primary = kGrades.where((g) => isPrimaryGrade(g)).toList();
    final high = kGrades.where((g) => !isPrimaryGrade(g)).toList();
    String short(String g) => g.replaceFirst('Grade ', '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Grade', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        const Text('Primary school',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final g in primary) _chip(short(g), g == grade, () => _pickGrade(g)),
          ],
        ),
        const SizedBox(height: 10),
        const Text('High school',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final g in high) _chip(short(g), g == grade, () => _pickGrade(g)),
          ],
        ),
        const SizedBox(height: 16),
        Text('Subjects for $grade',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final s in subjectsForGrade(grade))
              _chip(s, subjects.contains(s), () => _toggleSubject(s)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.yellowSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.navy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isPrimaryGrade(grade)
                      ? '$grade gets the playful look with short sessions.'
                      : '$grade gets the exam focused look with past papers and revision.',
                  style: const TextStyle(fontSize: 12, color: AppColors.navy),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
