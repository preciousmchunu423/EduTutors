import 'package:flutter/material.dart';

import '../../models/booking.dart';

import '../../models/user_account.dart';
import 'package:provider/provider.dart';

import '../../data/tutors_data.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/booking_view_model.dart';
import '../../theme/app_theme.dart';
import '../widgets/add_child_dialog.dart';
import '../widgets/common_widgets.dart';
import '../widgets/custom_button.dart';

class FindTutorsScreen extends StatefulWidget {
  const FindTutorsScreen({super.key});

  @override
  State<FindTutorsScreen> createState() => _FindTutorsScreenState();
}

class _FindTutorsScreenState extends State<FindTutorsScreen> {
  String _query = '';
  String _subject = 'All';
  String? _childId;
  bool _gradeOn = true;

  List<Child> _people(AuthViewModel auth) {
    if (auth.userRole == 'Parent') return auth.children;
    if (auth.userRole == 'Learner') {
      return [
        Child(
          id: 'me',
          name: auth.userName ?? 'Me',
          grade: auth.userGrade ?? '',
          subjects: auth.userSubjects,
        ),
      ];
    }
    return const [];
  }

  void _openBooking(Tutor tutor, String? learner) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BookingSheet(tutor: tutor, initialLearner: learner),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final people = _people(auth);
    final Child? p = people.isEmpty
        ? null
        : people.firstWhere((c) => c.id == _childId, orElse: () => people.first);

    final int? gradeNum = (p == null || !_gradeOn) ? null : gradeNumber(p.grade);
    final bool hasGrade = p != null && gradeNumber(p.grade) != null;

    final List<String> subjectOptions = (p != null && p.subjects.isNotEmpty)
        ? p.subjects
        : (hasGrade ? subjectsForGrade(p.grade) : {for (final t in kTutors) t.subject}.toList());
    final subject = subjectOptions.contains(_subject) ? _subject : 'All';

    final q = _query.trim().toLowerCase();
    final tutors = kTutors.where((t) {
      final gradeOk = gradeNum == null || t.teachesGrade(gradeNum);
      final subjectOk = subject == 'All'
          ? (p == null || p.subjects.isEmpty || !_gradeOn || p.subjects.contains(t.subject))
          : t.subject == subject;
      final queryOk = q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.subject.toLowerCase().contains(q);
      return gradeOk && subjectOk && queryOk;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Find a tutor')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search by name or subject',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          if (people.length > 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: people.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = people[i];
                  return ChoiceChip(
                    label: Text(c.name),
                    selected: c.id == p?.id,
                    showCheckmark: false,
                    selectedColor: AppColors.yellow,
                    labelStyle: TextStyle(
                      color: AppColors.navy,
                      fontWeight: c.id == p?.id ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) => setState(() {
                      _childId = c.id;
                      _subject = 'All';
                      _gradeOn = true;
                    }),
                  );
                },
              ),
            ),
          if (p != null && hasGrade)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _gradeOn
                        ? 'Showing tutors for ${p.name}'
                        : 'Showing all tutors',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _filterChip(
                        _gradeOn ? '${p.grade}  x' : 'Filter by ${p.grade}',
                        _gradeOn,
                        () => setState(() => _gradeOn = !_gradeOn),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subjectOptions.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final label = i == 0 ? 'All' : subjectOptions[i - 1];
                return _filterChip(label, label == subject, () => setState(() => _subject = label));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${tutors.length} ${tutors.length == 1 ? 'tutor' : 'tutors'} found',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ),
          Expanded(
            child: tutors.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No tutors found',
                    message: 'Try another subject, or look at tutors for all grades.',
                    action: _gradeOn && hasGrade
                        ? ElevatedButton(
                            onPressed: () => setState(() {
                              _gradeOn = false;
                              _subject = 'All';
                            }),
                            child: const Text('Show all tutors'),
                          )
                        : null,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: tutors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _TutorCard(
                      tutor: tutors[i],
                      onBook: () => _openBooking(tutors[i], p?.name),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  const _TutorCard({required this.tutor, required this.onBook});
  final Tutor tutor;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.yellow, width: 2),
                ),
                child: InitialsAvatar(tutor.initials, size: 48),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tutor.subject,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (tutor.badge != null) StatusChip(tutor.badge!, tone: ChipTone.yellow),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tutor.bio,
            style: const TextStyle(color: AppColors.textMuted, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 10),
          StatusChip(tutor.gradesLabel),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.yellowSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.yellow, size: 16),
                    const SizedBox(width: 3),
                    Text(
                      '${tutor.rating} (${tutor.reviews})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.people_outline_rounded, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 4),
              Text(
                '${tutor.students} learners',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const Spacer(),
              Text(
                tutor.priceLabel,
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppButton(label: 'Book a session', icon: Icons.event_available_rounded, onPressed: onBook),
        ],
      ),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({required this.tutor, this.initialLearner});
  final Tutor tutor;
  final String? initialLearner;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  static const List<int> _hours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17];

  late final List<DateTime> _days;
  DateTime? _day;
  int? _hour;
  String? _learner;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _days = List.generate(14, (i) => DateTime(now.year, now.month, now.day + i));
    _day = _days.first;
    _learner = widget.initialLearner;
  }

  bool _hourUnavailable(BookingViewModel bookings, int hour) {
    final d = _day!;
    final start = DateTime(d.year, d.month, d.day, hour);
    if (!start.isAfter(DateTime.now())) return true;
    return bookings.isSlotTaken(widget.tutor.id, start);
  }

  Future<void> _confirm(AuthViewModel auth, String learner) async {
    final d = _day;
    final h = _hour;
    if (d == null || h == null) {
      showAppSnack(context, 'Please choose a date and a time.', warning: true);
      return;
    }
    setState(() => _saving = true);
    final booking = Booking(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      ownerEmail: auth.userEmail ?? '',
      learnerName: learner,
      tutorId: widget.tutor.id,
      tutorName: widget.tutor.name,
      subject: widget.tutor.subject,
      start: DateTime(d.year, d.month, d.day, h),
      price: widget.tutor.pricePerHour,
    );
    await context.read<BookingViewModel>().add(booking);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Booked ${widget.tutor.name} for $learner on ${formatDate(booking.start)} at ${formatTime(booking.start)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final bookings = context.watch<BookingViewModel>();
    final isParent = auth.userRole == 'Parent';
    final children = auth.children;

    if (isParent && _learner == null && children.isNotEmpty) {
      _learner = children.first.name;
    }
    final learner = isParent ? _learner : auth.userName;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  InitialsAvatar(widget.tutor.initials, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book ${widget.tutor.name}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${widget.tutor.subject}  |  ${widget.tutor.priceLabel}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isParent) ...[
                const Text('Who is this lesson for?',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (children.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.yellowSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add your child first so the lesson can be booked in their name.',
                          style: TextStyle(height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        AppButton(
                          label: 'Add a child',
                          style: AppButtonStyle.accent,
                          expand: false,
                          onPressed: () => showAddChildDialog(context),
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in children)
                        ChoiceChip(
                          label: Text('${c.name}${c.grade.isEmpty ? '' : '  (${c.grade})'}'),
                          selected: _learner == c.name,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: _learner == c.name ? AppColors.white : AppColors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => _learner = c.name),
                        ),
                    ],
                  ),
                const SizedBox(height: 20),
              ],
              const Text('Choose a date', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SizedBox(
                height: 68,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final d = _days[i];
                    final selected = _day == d;
                    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() {
                        _day = d;
                        _hour = null;
                      }),
                      child: Container(
                        width: 56,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.blue : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.blue : AppColors.blueLine,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              names[d.weekday - 1],
                              style: TextStyle(
                                fontSize: 11,
                                color: selected ? AppColors.white : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${d.day}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: selected ? AppColors.white : AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('Choose a time', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final h in _hours)
                    Builder(builder: (_) {
                      final unavailable = _hourUnavailable(bookings, h);
                      final selected = _hour == h;
                      return ChoiceChip(
                        label: Text('${h.toString().padLeft(2, '0')}:00'),
                        selected: selected,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.white
                              : unavailable
                                  ? AppColors.textMuted
                                  : AppColors.blue,
                          fontWeight: FontWeight.w600,
                          decoration: unavailable ? TextDecoration.lineThrough : null,
                        ),
                        onSelected: unavailable ? null : (_) => setState(() => _hour = h),
                      );
                    }),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                label: _hour == null
                    ? 'Confirm booking'
                    : 'Confirm booking  |  R${widget.tutor.pricePerHour}',
                loading: _saving,
                onPressed: (learner == null || learner.isEmpty)
                    ? null
                    : () => _confirm(auth, learner),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
