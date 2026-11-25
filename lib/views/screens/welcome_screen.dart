import 'package:flutter/material.dart';


import '../../data/tutors_data.dart';
import '../../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/custom_button.dart';

/// Landing page for visitors who are not logged in.
/// Logged in users are sent straight to their dashboard by the app root.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('About EduTutors', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'EduTutors connects parents and learners with qualified tutors, and gives '
          'parents a clear view of how engaged their children are.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NavBar(),
                  const _Hero(),
                  const SizedBox(height: 36),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SectionTitle('Featured tutors'),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 196,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: kTutors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _TutorPreview(tutor: kTutors[i]),
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SectionTitle('How it works'),
                  ),
                  const SizedBox(height: 14),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _Step(
                          number: '1',
                          icon: Icons.person_add_alt_1_rounded,
                          title: 'Create an account',
                          text: 'Parents add their children, learners can link to a parent.',
                        ),
                        _Step(
                          number: '2',
                          icon: Icons.search_rounded,
                          title: 'Choose a tutor',
                          text: 'Browse by subject, compare ratings and prices, then pick a time.',
                        ),
                        _Step(
                          number: '3',
                          icon: Icons.insights_rounded,
                          title: 'Follow progress',
                          text: 'Parents see attendance, hours learned and upcoming lessons.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecor.card(color: AppColors.blueSoft, outlined: false),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Metric('500+', 'Learners'),
                        _Metric('50+', 'Tutors'),
                        _Metric('4.8', 'Avg rating'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '© 2026 EduTutors',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showAbout(context),
                          child: const Text('About'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        children: [
          const IconBadge(Icons.school_rounded, size: 40),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'EduTutors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('Log in', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusChip('Trusted by 500+ families', tone: ChipTone.yellow),
          const SizedBox(height: 18),
          const Text(
            'Find the right tutor for your child',
            style: TextStyle(
              fontSize: 34,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 72,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Book qualified tutors, learn at the right pace and follow every lesson as a parent.',
            style: TextStyle(fontSize: 16, height: 1.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(
                label: 'Get started',
                expand: false,
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
              AppButton(
                label: 'I have an account',
                style: AppButtonStyle.outline,
                expand: false,
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const _HeroVisual(),
        ],
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 200,
        width: double.infinity,
        color: AppColors.blue,
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Color(0x1FFFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0x14FFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Positioned(
              left: 18,
              top: 26,
              child: _FloatCard(
                icon: Icons.calculate_rounded,
                title: 'Mathematics',
                subtitle: 'Ms Dlamini, 4.9 rating',
              ),
            ),
            const Positioned(
              right: 18,
              bottom: 26,
              child: _FloatCard(
                icon: Icons.science_rounded,
                title: 'Physical Sciences',
                subtitle: 'Mr Nkosi, 4.8 rating',
                accent: true,
              ),
            ),
            Positioned(
              right: 22,
              top: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Book in 1 minute',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatCard extends StatelessWidget {
  const _FloatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x330B2A66), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconBadge(icon, size: 38, accent: accent),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TutorPreview extends StatelessWidget {
  const _TutorPreview({required this.tutor});
  final Tutor tutor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: AppDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(tutor.initials, size: 44),
              const Spacer(),
              if (tutor.badge != null) StatusChip(tutor.badge!, tone: ChipTone.yellow),
            ],
          ),
          const SizedBox(height: 12),
          Text(tutor.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 2),
          Text(
            tutor.subject,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.yellow, size: 16),
              const SizedBox(width: 3),
              Text('${tutor.rating}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                tutor.priceLabel,
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.icon,
    required this.title,
    required this.text,
  });

  final String number;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(color: AppColors.textMuted, height: 1.4, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.blue,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}
