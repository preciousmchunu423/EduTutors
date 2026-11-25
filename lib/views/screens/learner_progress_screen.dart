import 'package:flutter/material.dart';

import '../../models/booking.dart';

import '../../models/user_account.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/booking_view_model.dart';
import '../../theme/app_theme.dart';
import '../widgets/add_child_dialog.dart';
import '../widgets/common_widgets.dart';
import 'find_tutors_screen.dart';

/// Engagement tracking. Parents pick a child; learners see their own numbers.
/// Everything here is calculated from real bookings, so it stays truthful
/// as lessons are booked, attended and cancelled.
class LearnerProgressScreen extends StatefulWidget {
  const LearnerProgressScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<LearnerProgressScreen> createState() => _LearnerProgressScreenState();
}

class _LearnerProgressScreenState extends State<LearnerProgressScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final bookings = context.watch<BookingViewModel>();
    final isParent = auth.userRole == 'Parent';

    // Build the list of people we can show progress for.
    final people = <_Person>[];
    if (isParent) {
      for (final c in auth.children) {
        final owner = c.id.startsWith('acct:') ? c.id.substring(5) : (auth.userEmail ?? '');
        people.add(_Person(c.id, c.name, c.grade, owner));
      }
    } else {
      people.add(_Person(
        'me',
        auth.userName ?? 'Me',
        auth.userGrade ?? '',
        auth.userEmail ?? '',
      ));
    }

    Widget body;
    if (people.isEmpty) {
      body = EmptyState(
        icon: Icons.family_restroom_rounded,
        title: 'No children added yet',
        message: 'Add your child to start tracking their lessons and engagement.',
        action: ElevatedButton(
          onPressed: () => showAddChildDialog(context),
          child: const Text('Add a child'),
        ),
      );
    } else {
      final selected = people.firstWhere(
        (p) => p.id == _selectedId,
        orElse: () => people.first,
      );
      final summary = bookings.engagementFor(selected.ownerEmail, selected.name);
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (people.length > 1) ...[
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: people.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final p = people[i];
                  final isSel = p.id == selected.id;
                  return ChoiceChip(
                    label: Text(p.name),
                    selected: isSel,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: isSel ? AppColors.white : AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _selectedId = p.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          _Header(person: selected),
          const SizedBox(height: 16),
          Row(
            children: [
              StatTile(value: '${summary.completed}', label: 'Lessons done'),
              StatTile(value: '${summary.upcoming}', label: 'Upcoming', accent: true),
              StatTile(value: '${summary.hoursLearned}h', label: 'Hours learned'),
            ],
          ),
          const SizedBox(height: 20),
          _AttendanceCard(summary: summary),
          const SizedBox(height: 20),
          const SectionTitle('Subjects'),
          const SizedBox(height: 12),
          if (summary.subjects.isEmpty)
            _InfoBox(
              text: 'Subjects will appear here after the first completed lesson.',
              action: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FindTutorsScreen()),
                ),
                child: const Text('Book a lesson'),
              ),
            )
          else
            ..._subjectRows(summary),
          const SizedBox(height: 20),
          const SectionTitle('Activity'),
          const SizedBox(height: 12),
          _ActivityTile(
            icon: Icons.event_available_rounded,
            title: 'Next lesson',
            booking: summary.nextSession,
            emptyText: 'No lesson booked yet',
          ),
          const SizedBox(height: 10),
          _ActivityTile(
            icon: Icons.history_rounded,
            title: 'Last lesson',
            booking: summary.lastSession,
            emptyText: 'No completed lessons yet',
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: Text(isParent ? 'Child progress' : 'My progress'),
      ),
      body: body,
    );
  }

  List<Widget> _subjectRows(EngagementSummary summary) {
    final maxCount = summary.subjects.values.fold<int>(1, (a, b) => b > a ? b : a);
    return [
      for (final e in summary.subjects.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppDecor.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBadge(Icons.menu_book_rounded, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.key,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Text(
                      '${e.value} ${e.value == 1 ? 'lesson' : 'lessons'}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: e.value / maxCount,
                    minHeight: 6,
                    backgroundColor: AppColors.blueSoft,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }
}

class _Person {
  const _Person(this.id, this.name, this.grade, this.ownerEmail);
  final String id;
  final String name;
  final String grade;
  final String ownerEmail;
}

class _Header extends StatelessWidget {
  const _Header({required this.person});
  final _Person person;

  @override
  Widget build(BuildContext context) {
    final initial = person.name.isEmpty ? '?' : person.name[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card(color: AppColors.blueSoft, outlined: false),
      child: Row(
        children: [
          InitialsAvatar(initial, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                if (person.grade.isNotEmpty)
                  Text(person.grade, style: const TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.summary});
  final EngagementSummary summary;

  @override
  Widget build(BuildContext context) {
    final finished = summary.completed + summary.cancelled;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Attendance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Text(
                finished == 0 ? 'No data yet' : '${summary.attendancePercent}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: finished == 0 ? 0 : summary.attendancePercent / 100,
              minHeight: 10,
              backgroundColor: AppColors.blueSoft,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            finished == 0
                ? 'Attendance is the share of lessons attended instead of cancelled.'
                : '${summary.completed} attended, ${summary.cancelled} cancelled',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.booking,
    required this.emptyText,
  });

  final IconData icon;
  final String title;
  final Booking? booking;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecor.card(),
      child: Row(
        children: [
          IconBadge(icon, size: 40, accent: title == 'Next lesson'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  b == null ? emptyText : '${b.subject} with ${b.tutorName}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (b != null)
                  Text(
                    '${formatDate(b.start)} at ${formatTime(b.start)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text, this.action});
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card(color: AppColors.blueSoft, outlined: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(color: AppColors.textMuted, height: 1.4)),
          if (action != null) action!,
        ],
      ),
    );
  }
}
