
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/booking.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../viewmodels/booking_view_model.dart';
import '../../../viewmodels/tutor_view_model.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/common_widgets.dart';
import '../my_bookings_screen.dart';
import '../tutor_profile_screen.dart';
import '../tutor_availability_screen.dart';
import '../tutor_content_screen.dart';
import '../tutor_live_sessions_screen.dart';
import '../tutor_earnings_screen.dart';
import '../tutor_documents_screen.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<TutorViewModel>().loadFor(
            context.read<AuthViewModel>().userEmail,
          );
    });
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

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    final sessions = context
        .watch<BookingViewModel>()
        .forTutor(auth.userName);

    final upcoming = sessions
        .where((booking) => booking.status == BookingStatus.upcoming)
        .length;

    final learners = sessions
        .map((booking) => booking.learnerName)
        .toSet()
        .length;

    final actions = <_DashboardAction>[
      _DashboardAction(
        icon: Icons.calendar_month_rounded,
        title: 'My bookings',
        description: 'Manage your tutoring sessions',
        color: const Color(0xFF6951D9),
        onTap: () => _open(context, const MyBookingsScreen()),
      ),
      _DashboardAction(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Earnings',
        description: 'Track your tutoring income',
        color: const Color(0xFF159B83),
        onTap: () => _open(context, const TutorEarningsScreen()),
      ),
      _DashboardAction(
        icon: Icons.access_time_rounded,
        title: 'Availability',
        description: 'Manage your teaching hours',
        color: const Color(0xFFE49A35),
        onTap: () => _open(context, const TutorAvailabilityScreen()),
      ),
      _DashboardAction(
        icon: Icons.video_camera_front_rounded,
        title: 'Live sessions',
        description: 'Manage your online lessons',
        color: const Color(0xFF4285D4),
        onTap: () => _open(context, const TutorLiveSessionsScreen()),
      ),
      _DashboardAction(
        icon: Icons.menu_book_rounded,
        title: 'Learning materials',
        description: 'Share resources with learners',
        color: const Color(0xFFB45CC7),
        onTap: () => _open(context, const TutorContentScreen()),
      ),
      _DashboardAction(
        icon: Icons.verified_user_rounded,
        title: 'Qualifications',
        description: 'Manage verification documents',
        color: const Color(0xFFDA6D79),
        onTap: () => _open(context, const TutorDocumentsScreen()),
      ),
      _DashboardAction(
        icon: Icons.person_outline_rounded,
        title: 'My profile',
        description: 'Update your tutor profile',
        color: const Color(0xFF64748B),
        onTap: () => _open(context, const TutorProfileScreen()),
      ),
    ];

    final sidebar = _TutorSidebar(
      onNavigate: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            _open(context, const MyBookingsScreen());
            break;
          case 2:
            _open(context, const TutorAvailabilityScreen());
            break;
          case 3:
            _open(context, const TutorContentScreen());
            break;
          case 4:
            _open(context, const TutorEarningsScreen());
            break;
          case 5:
            _open(context, const TutorDocumentsScreen());
            break;
          case 6:
            _open(context, const TutorProfileScreen());
            break;
        }
      },
      onLogout: () => _logout(context),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      drawer: MediaQuery.sizeOf(context).width < 1050
          ? Drawer(
              width: 270,
              child: sidebar,
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1050;

          return Row(
            children: [
              if (wide)
                SizedBox(
                  width: 255,
                  child: sidebar,
                ),
              Expanded(
                child: _DashboardContent(
                  name: auth.userName ?? 'Tutor',
                  sessions: sessions,
                  totalSessions: sessions.length,
                  upcoming: upcoming,
                  learners: learners,
                  actions: actions,
                  isWide: wide,
                  onOpenBookings: () =>
                      _open(context, const MyBookingsScreen()),
                  onOpenQualifications: () =>
                      _open(context, const TutorDocumentsScreen()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// SIDEBAR
// ============================================================

class _TutorSidebar extends StatelessWidget {
  const _TutorSidebar({
    required this.onNavigate,
    required this.onLogout,
  });

  final ValueChanged<int> onNavigate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF25164F),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 28, 20, 35),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A72EC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EduTutors',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'TUTOR WORKSPACE',
                        style: TextStyle(
                          color: Color(0xFFB9AEDF),
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(25, 0, 20, 12),
              child: Text(
                'MENU',
                style: TextStyle(
                  color: Color(0xFF9C90C4),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            _SidebarItem(
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
              selected: true,
              onTap: () => onNavigate(0),
            ),
            _SidebarItem(
              icon: Icons.calendar_month_rounded,
              label: 'My bookings',
              onTap: () => onNavigate(1),
            ),
            _SidebarItem(
              icon: Icons.access_time_rounded,
              label: 'Availability',
              onTap: () => onNavigate(2),
            ),
            _SidebarItem(
              icon: Icons.menu_book_rounded,
              label: 'Learning content',
              onTap: () => onNavigate(3),
            ),
            _SidebarItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Earnings',
              onTap: () => onNavigate(4),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(25, 27, 20, 12),
              child: Text(
                'ACCOUNT',
                style: TextStyle(
                  color: Color(0xFF9C90C4),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            _SidebarItem(
              icon: Icons.verified_user_outlined,
              label: 'Qualifications',
              onTap: () => onNavigate(5),
            ),
            _SidebarItem(
              icon: Icons.person_outline_rounded,
              label: 'My profile',
              onTap: () => onNavigate(6),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(17),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF392969),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Color(0xFFFFD477),
                    size: 23,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Keep growing',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Share quality learning materials and help your learners succeed.',
                    style: TextStyle(
                      color: Color(0xFFD0C8E8),
                      height: 1.5,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            _SidebarItem(
              icon: Icons.logout_rounded,
              label: 'Log out',
              onTap: onLogout,
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
      child: Material(
        color: selected
            ? const Color(0xFF7257D5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected
                      ? Colors.white
                      : const Color(0xFFBEB4DD),
                  size: 19,
                ),
                const SizedBox(width: 13),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xFFD6D0E9),
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                if (selected) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD477),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MAIN DASHBOARD
// ============================================================

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.name,
    required this.sessions,
    required this.totalSessions,
    required this.upcoming,
    required this.learners,
    required this.actions,
    required this.isWide,
    required this.onOpenBookings,
    required this.onOpenQualifications,
  });

  final String name;
  final List<Booking> sessions;
  final int totalSessions;
  final int upcoming;
  final int learners;
  final List<_DashboardAction> actions;
  final bool isWide;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenQualifications;

  @override
  Widget build(BuildContext context) {
    final firstName = name.trim().split(' ').first;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 38 : 20,
          vertical: 25,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1350),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(isWide: isWide),
                const SizedBox(height: 30),

                _WelcomeSection(
                  name: firstName,
                  upcoming: upcoming,
                  onOpenBookings: onOpenBookings,
                ),

                const SizedBox(height: 18),

                _QualificationBanner(
                  onTap: onOpenQualifications,
                ),

                const SizedBox(height: 27),

                const _SectionTitle(
                  title: 'Your teaching overview',
                  subtitle: 'A snapshot of your tutoring activity.',
                ),

                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.count(
                      crossAxisCount:
                          constraints.maxWidth >= 800 ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 13,
                      mainAxisSpacing: 13,
                      childAspectRatio:
                          constraints.maxWidth < 450 ? 1.45 : 1.75,
                      children: [
                        _MetricCard(
                          label: 'Total sessions',
                          value: '$totalSessions',
                          icon: Icons.menu_book_rounded,
                          color: const Color(0xFF7055D9),
                          detail: 'All bookings',
                        ),
                        _MetricCard(
                          label: 'Upcoming',
                          value: '$upcoming',
                          icon: Icons.event_available_rounded,
                          color: const Color(0xFFE59A38),
                          detail: 'Scheduled lessons',
                        ),
                        _MetricCard(
                          label: 'Learners',
                          value: '$learners',
                          icon: Icons.groups_rounded,
                          color: const Color(0xFF219B83),
                          detail: 'Unique learners',
                        ),
                        _MetricCard(
                          label: 'Workspace',
                          value: '${actions.length}',
                          icon: Icons.dashboard_customize_rounded,
                          color: const Color(0xFF4589CE),
                          detail: 'Available tools',
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),

                _SectionTitle(
                  title: 'Manage your workspace',
                  subtitle:
                      'Everything you need to run your tutoring business.',
                  trailing: Text(
                    '${actions.length} tools',
                    style: const TextStyle(
                      color: Color(0xFF786B9D),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns =
                        constraints.maxWidth >= 1000
                            ? 3
                            : constraints.maxWidth >= 600
                                ? 2
                                : 1;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: actions.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 112,
                      ),
                      itemBuilder: (context, index) {
                        return _WorkspaceCard(
                          action: actions[index],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),

                _SectionTitle(
                  title: 'Learner activity',
                  subtitle:
                      'Your learners and tutoring commitments.',
                  trailing: TextButton(
                    onPressed: onOpenBookings,
                    child: const Text('View bookings'),
                  ),
                ),

                const SizedBox(height: 15),

                _LearnerActivityPanel(
                  sessions: sessions,
                  upcoming: upcoming,
                  onOpenBookings: onOpenBookings,
                ),

                const SizedBox(height: 30),
                const _Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TOP BAR
// ============================================================

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Row(
      children: [
        if (!isWide) ...[
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
              color: const Color(0xFF30205D),
            ),
          ),
          const SizedBox(width: 5),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TUTOR WORKSPACE',
                style: TextStyle(
                  color: Color(0xFF8A7DA8),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: const Color(0xFF281B4E),
                  fontWeight: FontWeight.w800,
                  fontSize: isWide ? 25 : 21,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFEAE6F2)),
          ),
          child: Row(
            children: [
              const ProfileAvatar(
                radius: 19,
                backgroundColor: Color(0xFFECE5FF),
                iconColor: AppColors.purple,
              ),
              if (isWide) ...[
                const SizedBox(width: 9),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 125),
                  child: Text(
                    auth.userName ?? 'Tutor',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF30205D),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WELCOME SECTION
// ============================================================

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({
    required this.name,
    required this.upcoming,
    required this.onOpenBookings,
  });

  final String name;
  final int upcoming;
  final VoidCallback onOpenBookings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF33206C),
            Color(0xFF7456CF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -45,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 85,
            bottom: -90,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(27),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth > 550;

                final intro = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'YOUR TEACHING SPACE',
                        style: TextStyle(
                          color: Color(0xFFE9E1FF),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      'Hello, $name!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Inspire learners. Share knowledge.\nMake every lesson count.',
                      style: TextStyle(
                        color: Color(0xFFE6DEFF),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 21),
                    ElevatedButton.icon(
                      onPressed: onOpenBookings,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                      ),
                      label: const Text('Manage my bookings'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF39256F),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                );

                final summary = Container(
                  width: horizontal ? 205 : double.infinity,
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.13),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.event_note_rounded,
                        color: Color(0xFFFFD477),
                        size: 25,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$upcoming',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Upcoming sessions',
                        style: TextStyle(
                          color: Color(0xFFE6DEFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Stay organised and keep your learners on track.',
                        style: TextStyle(
                          color: Color(0xFFD6CCF5),
                          fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );

                if (horizontal) {
                  return Row(
                    children: [
                      Expanded(child: intro),
                      const SizedBox(width: 20),
                      summary,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    intro,
                    const SizedBox(height: 20),
                    summary,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUALIFICATION UPLOAD BANNER
// ============================================================

class _QualificationBanner extends StatelessWidget {
  const _QualificationBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE3DAFF),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7055D9).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 440;

          final information = Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF7055D9),
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tutor qualification verification',
                      style: TextStyle(
                        color: Color(0xFF30224F),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Upload your documents for organisation admin review.',
                      style: TextStyle(
                        color: Color(0xFF898199),
                        fontSize: 10,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final button = SizedBox(
            height: 43,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(
                Icons.upload_file_rounded,
                size: 17,
              ),
              label: const Text('Upload Qualifications'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7055D9),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                information,
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: button),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: information),
              const SizedBox(width: 12),
              button,
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// SECTION HEADING
// ============================================================

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF2A1C50),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF88819B),
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

// ============================================================
// STATISTICS
// ============================================================

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.detail,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE8F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const Spacer(),
              const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFFB0A8C1),
                size: 17,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2B2050),
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF51476B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF9992A9),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WORKSPACE ACTIONS
// ============================================================

class _DashboardAction {
  const _DashboardAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFECE8F3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF30224F),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      action.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8D879E),
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFAAA2BB),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LEARNER ACTIVITY
// ============================================================

class _LearnerActivityPanel extends StatelessWidget {
  const _LearnerActivityPanel({
    required this.sessions,
    required this.upcoming,
    required this.onOpenBookings,
  });

  final List<Booking> sessions;
  final int upcoming;
  final VoidCallback onOpenBookings;

  @override
  Widget build(BuildContext context) {
    final learnerNames = sessions
        .map((booking) => booking.learnerName)
        .toSet()
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFECE8F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBFF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Color(0xFF7055D9),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your learners',
                      style: TextStyle(
                        color: Color(0xFF30224F),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Learners associated with your bookings',
                      style: TextStyle(
                        color: Color(0xFF928BA3),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${learnerNames.length}',
                style: const TextStyle(
                  color: Color(0xFF7055D9),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 17),
            child: Divider(
              color: Color(0xFFF0EDF5),
              height: 1,
            ),
          ),
          if (learnerNames.isEmpty)
            const _EmptyLearners()
          else
            ...learnerNames.take(4).map(
                  (learner) => Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: const Color(0xFFEDE7FF),
                          child: Text(
                            learner.isNotEmpty
                                ? learner[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Color(0xFF7055D9),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            learner,
                            style: const TextStyle(
                              color: Color(0xFF40365B),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Text(
                          'Booked learner',
                          style: TextStyle(
                            color: Color(0xFF9992A9),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          if (learnerNames.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onOpenBookings,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                ),
                label: const Text('Manage bookings'),
              ),
            ),
          if (upcoming > 0 && learnerNames.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFFD3942E),
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'You have $upcoming upcoming sessions. Check your bookings to review them.',
                      style: const TextStyle(
                        color: Color(0xFF876322),
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyLearners extends StatelessWidget {
  const _EmptyLearners();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              color: Colors.grey.shade400,
              size: 34,
            ),
            const SizedBox(height: 10),
            const Text(
              'No learners yet',
              style: TextStyle(
                color: Color(0xFF51476B),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Your learner activity will appear here when bookings are made.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9992A9),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FOOTER
// ============================================================

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'EduTutors  •  Empowering learning, one lesson at a time.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFA29AAF),
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
