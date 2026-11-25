
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/booking.dart';
import '../../../data/tutors_data.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../viewmodels/booking_view_model.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/subject_icon.dart';
import '../find_tutors_screen.dart';
import '../learner_progress_screen.dart';
import '../live_classes_screen.dart';
import '../my_bookings_screen.dart';
import '../rate_tutors_screen.dart';
import '../study_materials_screen.dart';

const _purple = Color(0xFF5426A8);
const _deepPurple = Color(0xFF29105D);
const _lavender = Color(0xFFF1EBFF);
const _page = Color(0xFFF8F6FC);
const _muted = Color(0xFF77718A);

void _open(BuildContext context, Widget screen) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => screen),
  );
}

Future<void> _logout(BuildContext context) async {
  final ok = await confirmDialog(
    context,
    title: 'Log out',
    message: 'Are you sure you want to log out?',
    confirmLabel: 'Log out',
  );

  if (!ok || !context.mounted) return;

  Navigator.of(context).popUntil((route) => route.isFirst);
  await context.read<AuthViewModel>().logout();
}

class LearnerDashboard extends StatelessWidget {
  const LearnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    final bookings = context
        .watch<BookingViewModel>()
        .forOwner(auth.userEmail);

    final subjects = auth.userSubjects.isNotEmpty
        ? auth.userSubjects
        : subjectsForGrade(auth.userGrade);

    final data = _HomeData(
      name: auth.userName ?? 'Learner',
      grade: auth.userGrade ?? '',
      subjects: subjects,
      bookings: bookings,
    );

    return isPrimaryGrade(auth.userGrade)
        ? _PrimaryHome(data: data)
        : _HighSchoolHome(data: data);
  }
}

class _HomeData {
  const _HomeData({
    required this.name,
    required this.grade,
    required this.subjects,
    required this.bookings,
  });

  final String name;
  final String grade;
  final List<String> subjects;
  final List<Booking> bookings;

  List<Booking> get upcoming {
    final result = bookings
        .where((booking) => booking.status == BookingStatus.upcoming)
        .toList();

    result.sort((a, b) => a.start.compareTo(b.start));
    return result;
  }

  int completedFor(String subject) {
    return bookings
        .where(
          (booking) =>
              booking.subject == subject &&
              booking.status == BookingStatus.completed,
        )
        .length;
  }

  int get completed {
    return bookings
        .where((booking) => booking.status == BookingStatus.completed)
        .length;
  }

  int get tutorCount {
    return bookings.map((booking) => booking.tutorId).toSet().length;
  }
}

// =====================================================
// PRIMARY SCHOOL DASHBOARD
// =====================================================

class _PrimaryHome extends StatelessWidget {
  const _PrimaryHome({required this.data});

  final _HomeData data;

  @override
  Widget build(BuildContext context) {
    final next = data.upcoming.isEmpty ? null : data.upcoming.first;

    final links = <_Link>[
      _Link(
        Icons.search_rounded,
        'Find tutors',
        () => _open(context, const FindTutorsScreen()),
      ),
      _Link(
        Icons.calendar_month_rounded,
        'My lessons',
        () => _open(context, const MyBookingsScreen()),
      ),
      _Link(
        Icons.menu_book_rounded,
        'Materials',
        () => _open(context, const StudyMaterialsScreen()),
      ),
      _Link(
        Icons.star_rounded,
        'Rate tutors',
        () => _open(context, const RateTutorsScreen()),
      ),
    ];

    return Scaffold(
      backgroundColor: _page,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _PrimaryHeader(data: data),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionTitle(
                  title: 'Your next lesson',
                  subtitle: 'A little learning goes a long way!',
                ),
                const SizedBox(height: 12),
                _NextLessonCard(
                  booking: next,
                  onTap: () => _open(
                    context,
                    next == null
                        ? const FindTutorsScreen()
                        : const MyBookingsScreen(),
                  ),
                ),
                const SizedBox(height: 26),
                _SectionTitle(
                  title: 'Explore your subjects',
                  subtitle: 'Choose a subject and keep practising.',
                  trailing: Text(
                    '${data.subjects.length} subjects',
                    style: const TextStyle(
                      color: _purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.subjects.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.12,
                  ),
                  itemBuilder: (context, index) {
                    final subject = data.subjects[index];

                    return _PrimarySubjectTile(
                      subject: subject,
                      lessons: data.completedFor(subject),
                      accent: index,
                      onTap: () =>
                          _open(context, const FindTutorsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 27),
                const _SectionTitle(
                  title: 'Learning corner',
                  subtitle: 'Everything you need, all in one place.',
                ),
                const SizedBox(height: 13),
                _PrimaryQuickLinks(links: links),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryHeader extends StatelessWidget {
  const _PrimaryHeader({required this.data});

  final _HomeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF5727A8),
            Color(0xFF8A60DD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'EDUTUTORS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Log out',
                  onPressed: () => _logout(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HELLO, ${data.name.toUpperCase()}!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFE7DBFF),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ready for a\nbright day of learning?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        data.grade,
                        style: const TextStyle(
                          color: Color(0xFFE9DFFF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 112,
                  width: 105,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Color(0xFFFFD879),
                    size: 65,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 23),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  _HeaderMetric(
                    value: '${data.upcoming.length}',
                    label: 'Upcoming',
                  ),
                  _HeaderMetric(
                    value: '${data.completed}',
                    label: 'Completed',
                  ),
                  _HeaderMetric(
                    value: '${data.subjects.length}',
                    label: 'Subjects',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE8DEFF),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextLessonCard extends StatelessWidget {
  const _NextLessonCard({
    required this.booking,
    required this.onTap,
  });

  final Booking? booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasBooking = booking != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: const Color(0xFFECE5F8),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A29105D),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _lavender,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'UP NEXT',
                      style: TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    color: _purple,
                    size: 19,
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2D8),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFFCE8B20),
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasBooking
                              ? booking!.subject
                              : 'No lesson booked yet',
                          style: const TextStyle(
                            color: _deepPurple,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasBooking
                              ? 'With ${booking!.tutorName}'
                              : 'Find a tutor and start learning.',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasBooking) ...[
                const SizedBox(height: 15),
                const Divider(
                  color: Color(0xFFF0ECF5),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: _purple,
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      formatDate(booking!.start),
                      style: const TextStyle(
                        color: _deepPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time_rounded,
                      color: _purple,
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      formatTime(booking!.start),
                      style: const TextStyle(
                        color: _deepPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    hasBooking ? 'View my lesson' : 'Find a tutor',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimarySubjectTile extends StatelessWidget {
  const _PrimarySubjectTile({
    required this.subject,
    required this.lessons,
    required this.accent,
    required this.onTap,
  });

  final String subject;
  final int lessons;
  final int accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFF0E9FF),
      const Color(0xFFFFF1D9),
      const Color(0xFFE5F5F0),
      const Color(0xFFE6F0FF),
    ];

    final iconColors = [
      _purple,
      const Color(0xFFB47718),
      const Color(0xFF25846B),
      const Color(0xFF3971C4),
    ];

    final index = accent % colors.length;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFECE7F3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  subjectIcon(subject),
                  color: iconColors[index],
                  size: 27,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _deepPurple,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lessons == 1
                        ? '1 lesson completed'
                        : '$lessons lessons completed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryQuickLinks extends StatelessWidget {
  const _PrimaryQuickLinks({required this.links});

  final List<_Link> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              child: InkWell(
                onTap: link.onTap,
                borderRadius: BorderRadius.circular(17),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: _lavender,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          link.icon,
                          color: _purple,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          link.title,
                          style: const TextStyle(
                            color: _deepPurple,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =====================================================
// HIGH SCHOOL DASHBOARD
// =====================================================

class _HighSchoolHome extends StatelessWidget {
  const _HighSchoolHome({required this.data});

  final _HomeData data;

  @override
  Widget build(BuildContext context) {
    final links = <_Link>[
      _Link(
        Icons.search_rounded,
        'Find tutors',
        () => _open(context, const FindTutorsScreen()),
      ),
      _Link(
        Icons.calendar_month_rounded,
        'Bookings',
        () => _open(context, const MyBookingsScreen()),
      ),
      _Link(
        Icons.insights_rounded,
        'Progress',
        () => _open(context, const LearnerProgressScreen()),
      ),
      _Link(
        Icons.menu_book_rounded,
        'Materials',
        () => _open(context, const StudyMaterialsScreen()),
      ),
      _Link(
        Icons.video_call_rounded,
        'Live classes',
        () => _open(context, const LiveClassesScreen()),
      ),
      _Link(
        Icons.star_rounded,
        'Rate tutors',
        () => _open(context, const RateTutorsScreen()),
      ),
    ];

    return Scaffold(
      backgroundColor: _page,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HighSchoolHeader(data: data),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionTitle(
                  title: 'Your subjects',
                  subtitle:
                      'Stay consistent. Small steps lead to big results.',
                  trailing: Text(
                    '${data.subjects.length} subjects',
                    style: const TextStyle(
                      color: _purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                for (var i = 0; i < data.subjects.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _HighSchoolSubjectCard(
                      subject: data.subjects[i],
                      completed: data.completedFor(data.subjects[i]),
                      index: i,
                    ),
                  ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'Quick access',
                  subtitle: 'Your learning tools.',
                ),
                const SizedBox(height: 13),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: links.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 11,
                    mainAxisSpacing: 11,
                    childAspectRatio: 0.96,
                  ),
                  itemBuilder: (context, index) {
                    return _QuickTile(link: links[index]);
                  },
                ),
                const SizedBox(height: 25),
                _SectionTitle(
                  title: 'Upcoming sessions',
                  subtitle: 'Your scheduled tutoring sessions.',
                  trailing: data.upcoming.isEmpty
                      ? null
                      : TextButton(
                          onPressed: () =>
                              _open(context, const MyBookingsScreen()),
                          child: const Text('See all'),
                        ),
                ),
                const SizedBox(height: 12),
                if (data.upcoming.isEmpty)
                  _NoSessionsCard(
                    onTap: () =>
                        _open(context, const FindTutorsScreen()),
                  )
                else
                  for (final booking in data.upcoming.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SessionTile(booking: booking),
                    ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighSchoolHeader extends StatelessWidget {
  const _HighSchoolHeader({required this.data});

  final _HomeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _deepPurple,
            _purple,
            Color(0xFF8860D5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 27,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'EDUTUTORS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Log out',
                  onPressed: () => _logout(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),
            Text(
              'WELCOME BACK, ${data.name.toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFE5D9FF),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              data.grade.isEmpty
                  ? 'Ready to study?'
                  : '${data.grade} is yours to conquer.',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  _HeaderMetric(
                    value: '${data.upcoming.length}',
                    label: 'Upcoming',
                  ),
                  _HeaderMetric(
                    value: '${data.completed}',
                    label: 'Completed',
                  ),
                  _HeaderMetric(
                    value: '${data.tutorCount}',
                    label: 'Tutors',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighSchoolSubjectCard extends StatelessWidget {
  const _HighSchoolSubjectCard({
    required this.subject,
    required this.completed,
    required this.index,
  });

  final String subject;
  final int completed;
  final int index;

  @override
  Widget build(BuildContext context) {
    final backgrounds = [
      const Color(0xFFF0E9FF),
      const Color(0xFFFFF2DF),
      const Color(0xFFE7F5F0),
      const Color(0xFFE8F0FF),
    ];

    final colors = [
      _purple,
      const Color(0xFFB47718),
      const Color(0xFF25846B),
      const Color(0xFF3971C4),
    ];

    final i = index % backgrounds.length;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFECE7F3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: backgrounds[i],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              subjectIcon(subject),
              color: colors[i],
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    color: _deepPurple,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed lessons completed',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Color(0xFF9B91B1),
            size: 15,
          ),
        ],
      ),
    );
  }
}

class _NoSessionsCard extends StatelessWidget {
  const _NoSessionsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAFE),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: _purple,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No lessons booked yet',
                  style: TextStyle(
                    color: _deepPurple,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Find a tutor to get started.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: _purple,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SHARED COMPONENTS
// =====================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _deepPurple,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _Link {
  const _Link(
    this.icon,
    this.title,
    this.onTap,
  );

  final IconData icon;
  final String title;
  final VoidCallback onTap;
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.link});

  final _Link link;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: link.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFFECE7F3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: _lavender,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  link.icon,
                  color: _purple,
                  size: 23,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                link.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _deepPurple,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFECE7F3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _lavender,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: _purple,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.subject,
                  style: const TextStyle(
                    color: _deepPurple,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'With ${booking.tutorName}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${formatDate(booking.start)} · ${formatRange(booking)}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: _purple,
          ),
        ],
      ),
    );
  }
}
