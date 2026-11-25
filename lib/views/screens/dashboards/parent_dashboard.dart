
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/booking.dart';
import '../../../models/user_account.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../viewmodels/booking_view_model.dart';
import '../../../theme/app_theme.dart';

import '../../widgets/add_child_dialog.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/profile_avatar.dart';

import '../contact_tutor_screen.dart';
import '../find_tutors_screen.dart';
import '../learner_progress_screen.dart';
import '../my_bookings_screen.dart';
import '../payments_screen.dart';

const Color _purple = Color(0xFF6035C9);
const Color _darkPurple = Color(0xFF29165B);
const Color _lightPurple = Color(0xFFF0EBFF);
const Color _pageBackground = Color(0xFFF8F7FC);

Future<void> _confirmLogout(BuildContext context) async {
  final ok = await confirmDialog(
    context,
    title: 'Log out',
    message: 'Are you sure you want to log out?',
    confirmLabel: 'Log out',
  );

  if (!ok || !context.mounted) return;

  Navigator.of(context).popUntil((r) => r.isFirst);
  await context.read<AuthViewModel>().logout();
}

// =====================================================
// PARENT DASHBOARD
// =====================================================

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _ParentHomePage(
        onSwitchTab: (index) => setState(() => _index = index),
      ),
      const LearnerProgressScreen(embedded: true),
      const MyBookingsScreen(embedded: true),
      const _ParentProfilePage(),
    ];

    return Scaffold(
      backgroundColor: _pageBackground,
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: _lightPurple,
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() => _index = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: _purple),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded, color: _purple),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
              color: _purple,
            ),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: _purple),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PARENT HOME
// =====================================================

class _ParentHomePage extends StatelessWidget {
  const _ParentHomePage({
    required this.onSwitchTab,
  });

  final ValueChanged<int> onSwitchTab;

  void _push(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final bookings = context.watch<BookingViewModel>();

    final children = auth.children;
    final mine = bookings.forOwner(auth.userEmail);

    final upcoming = mine
        .where((b) => b.status == BookingStatus.upcoming)
        .length;

    final completed = mine
        .where((b) => b.status == BookingStatus.completed)
        .length;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(
              Icons.school_rounded,
              color: _purple,
              size: 27,
            ),
            SizedBox(width: 9),
            Text(
              'EduTutors',
              style: TextStyle(
                color: _darkPurple,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () => _confirmLogout(context),
            icon: const Icon(
              Icons.logout_rounded,
              color: _darkPurple,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WELCOME SECTION
            _WelcomeCard(
              name: auth.userName ?? 'Parent',
              childrenCount: children.length,
              upcoming: upcoming,
              completed: completed,
            ),

            const SizedBox(height: 27),

            // CHILDREN SECTION
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your children',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _darkPurple,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showAddChildDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 19),
                  label: const Text('Add child'),
                  style: TextButton.styleFrom(
                    foregroundColor: _purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            if (children.isEmpty)
              _EmptyChildrenCard(
                onAdd: () => showAddChildDialog(context),
              )
            else
              for (final child in children)
                Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: _ChildCard(
                    child: child,
                    summary: bookings.engagementFor(
                      child.id.startsWith('acct:')
                          ? child.id.substring(5)
                          : (auth.userEmail ?? ''),
                      child.name,
                    ),
                    onTap: () => onSwitchTab(1),
                  ),
                ),

            const SizedBox(height: 17),

            // QUICK ACTIONS
            const Text(
              'Quick actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _darkPurple,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Everything you need to support your child.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.65,
              children: [
                _ActionCard(
                  icon: Icons.search_rounded,
                  title: 'Find tutors',
                  subtitle: 'Explore available tutors',
                  color: const Color(0xFFEDE6FF),
                  iconColor: _purple,
                  onTap: () => _push(
                    context,
                    const FindTutorsScreen(),
                  ),
                ),
                _ActionCard(
                  icon: Icons.calendar_month_rounded,
                  title: 'Bookings',
                  subtitle: 'Manage lesson sessions',
                  color: const Color(0xFFE4F0FF),
                  iconColor: const Color(0xFF3274C8),
                  onTap: () => onSwitchTab(2),
                ),
                _ActionCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Contact tutor',
                  subtitle: 'Get in touch',
                  color: const Color(0xFFFFEEDB),
                  iconColor: const Color(0xFFD58A28),
                  onTap: () => _push(
                    context,
                    const ContactTutorScreen(),
                  ),
                ),
                _ActionCard(
                  icon: Icons.payments_rounded,
                  title: 'Payments',
                  subtitle: 'View your payments',
                  color: const Color(0xFFE1F6EC),
                  iconColor: const Color(0xFF26966A),
                  onTap: () => _push(
                    context,
                    const PaymentsScreen(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // SUPPORT BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE9E2FA),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 47,
                    width: 47,
                    decoration: BoxDecoration(
                      color: _lightPurple,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
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
                          'Every lesson counts',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _darkPurple,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Keep track of your child’s learning journey.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
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

// =====================================================
// WELCOME CARD
// =====================================================

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.name,
    required this.childrenCount,
    required this.upcoming,
    required this.completed,
  });

  final String name;
  final int childrenCount;
  final int upcoming;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _darkPurple,
            _purple,
            Color(0xFF865BE0),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.family_restroom_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFFD88C),
                size: 25,
              ),
            ],
          ),

          const SizedBox(height: 23),

          const Text(
            'Supporting their journey,',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const Text(
            'one lesson at a time.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 23),

          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                _HeroStat(
                  value: '$childrenCount',
                  label: 'Children',
                  icon: Icons.people_alt_outlined,
                ),
                _HeroStat(
                  value: '$upcoming',
                  label: 'Upcoming',
                  icon: Icons.event_available_outlined,
                ),
                _HeroStat(
                  value: '$completed',
                  label: 'Completed',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 19,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// EMPTY CHILDREN
// =====================================================

class _EmptyChildrenCard extends StatelessWidget {
  const _EmptyChildrenCard({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE9E2FA),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 66,
            width: 66,
            decoration: const BoxDecoration(
              color: _lightPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_care_rounded,
              color: _purple,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your learning journey starts here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _darkPurple,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Add your child to manage tutoring sessions, '
            'find tutors and follow their academic progress.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your child'),
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CHILD CARD
// =====================================================

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.summary,
    required this.onTap,
  });

  final Child child;
  final EngagementSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final finished = summary.completed + summary.cancelled;
    final next = summary.nextSession;

    final attendance = finished == 0
        ? 0.0
        : (summary.attendancePercent / 100).clamp(0.0, 1.0);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: const Color(0xFFEAE5F5),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  InitialsAvatar(
                    child.name.isEmpty
                        ? '?'
                        : child.name[0].toUpperCase(),
                    size: 52,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _darkPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          child.grade.isEmpty
                              ? 'Learner'
                              : child.grade,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: _lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: _purple,
                      size: 18,
                    ),
                  ),
                ],
              ),

              if (child.subjects.isNotEmpty) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final subject in child.subjects.take(3))
                        StatusChip(subject),
                      if (child.subjects.length > 3)
                        StatusChip(
                          '+${child.subjects.length - 3}',
                          tone: ChipTone.neutral,
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 17),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attendance',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    finished == 0
                        ? 'No data yet'
                        : '${summary.attendancePercent}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: _purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: attendance,
                  minHeight: 7,
                  backgroundColor: _lightPurple,
                  color: _purple,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F6FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_note_rounded,
                      color: _purple,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        next == null
                            ? 'No lesson booked'
                            : 'Next: ${next.subject}, '
                                '${formatDate(next.start)} '
                                'at ${formatTime(next.start)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _darkPurple,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// QUICK ACTION CARD
// =====================================================

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFFEAE5F5),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _darkPurple,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// PARENT PROFILE
// =====================================================

class _ParentProfilePage extends StatelessWidget {
  const _ParentProfilePage();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final children = auth.children;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _pageBackground,
        elevation: 0,
        title: const Text(
          'My profile',
          style: TextStyle(
            color: _darkPurple,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          // PROFILE HEADER
          Container(
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _darkPurple,
                  _purple,
                ],
              ),
              borderRadius: BorderRadius.circular(23),
            ),
            child: Column(
              children: [
                const ProfileAvatar(
                  radius: 43,
                  backgroundColor: Colors.white,
                  icon: Icons.family_restroom_rounded,
                  iconColor: _purple,
                  showCamera: true,
                ),
                const SizedBox(height: 13),
                Text(
                  auth.userName ?? 'Parent',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  auth.userEmail ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'PARENT ACCOUNT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'My children',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: _darkPurple,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => showAddChildDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (children.isEmpty)
            const _ProfileEmptyCard()
          else
            for (final child in children)
              Container(
                margin: const EdgeInsets.only(bottom: 11),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: const Color(0xFFEAE5F5),
                  ),
                ),
                child: Row(
                  children: [
                    InitialsAvatar(
                      child.name.isEmpty
                          ? '?'
                          : child.name[0].toUpperCase(),
                      size: 43,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _darkPurple,
                            ),
                          ),
                          if (child.grade.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              child.grade,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!child.id.startsWith('acct:'))
                      IconButton(
                        tooltip: 'Remove child',
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          final ok = await confirmDialog(
                            context,
                            title: 'Remove ${child.name}?',
                            message:
                                'Their profile will be removed from your account.',
                            confirmLabel: 'Remove',
                          );

                          if (ok && context.mounted) {
                            await context
                                .read<AuthViewModel>()
                                .removeChild(child.id);
                          }
                        },
                      )
                    else
                      const StatusChip('Linked account'),
                  ],
                ),
              ),

          const SizedBox(height: 24),

          // LOGOUT
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(
                  color: Color(0xFFFFD6D6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEmptyCard extends StatelessWidget {
  const _ProfileEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFEAE5F5),
        ),
      ),
      child: const Text(
        'No children added yet.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
