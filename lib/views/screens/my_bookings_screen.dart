import 'package:flutter/material.dart';

import '../../models/booking.dart';

import '../../models/user_account.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/booking_view_model.dart';
import '../../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'find_tutors_screen.dart';

/// Shows bookings for whoever is logged in:
/// learners and parents see the lessons they booked, tutors see their sessions.
/// Parents can filter by child.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key, this.embedded = false});

  /// When true the screen is used as a tab, so it hides its own back button.
  final bool embedded;

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  String _filter = 'All';
  String _child = 'All children';

  static const _filters = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  bool _matches(Booking b) {
    switch (_filter) {
      case 'Upcoming':
        return b.status == BookingStatus.upcoming;
      case 'Completed':
        return b.status == BookingStatus.completed;
      case 'Cancelled':
        return b.status == BookingStatus.cancelled;
      default:
        return true;
    }
  }

  String _countdown(DateTime start) {
    final diff = start.difference(DateTime.now());
    if (diff.isNegative) return 'Starting now';
    if (diff.inDays > 0) return 'In ${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
    return 'In ${diff.inMinutes}m';
  }

  Future<void> _cancel(Booking b) async {
    final ok = await confirmDialog(
      context,
      title: 'Cancel this lesson?',
      message: '${b.subject} with ${b.tutorName} on ${formatDate(b.start)} at ${formatTime(b.start)}.',
      confirmLabel: 'Cancel lesson',
      cancelLabel: 'Keep it',
    );
    if (!ok || !mounted) return;
    await context.read<BookingViewModel>().cancel(b.id);
    if (!mounted) return;
    showAppSnack(context, 'Lesson cancelled.');
  }

  Future<void> _reschedule(Booking b) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: b.start.isAfter(now) ? b.start : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: b.start.hour, minute: 0),
    );
    if (time == null || !mounted) return;

    final newStart = DateTime(date.year, date.month, date.day, time.hour, 0);
    final provider = context.read<BookingViewModel>();
    if (!newStart.isAfter(DateTime.now())) {
      showAppSnack(context, 'Please choose a time in the future.', warning: true);
      return;
    }
    if (provider.isSlotTaken(b.tutorId, newStart, ignoreId: b.id)) {
      showAppSnack(context, '${b.tutorName} is already booked at that time.', warning: true);
      return;
    }
    await provider.reschedule(b.id, newStart);
    if (!mounted) return;
    showAppSnack(context, 'Moved to ${formatDate(newStart)} at ${formatTime(newStart)}.');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final provider = context.watch<BookingViewModel>();
    final isTutor = auth.userRole == 'Tutor';
    final isParent = auth.userRole == 'Parent';

    final all = isTutor
        ? provider.forTutor(auth.userName)
        : provider.forOwner(auth.userEmail);

    final children = isParent ? auth.children : const <Child>[];
    final list = all
        .where(_matches)
        .where((b) => _child == 'All children' || b.learnerName == _child)
        .toList();

    final upcomingCount = all.where((b) => b.status == BookingStatus.upcoming).length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: Text(isTutor ? 'My sessions' : 'Bookings'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                StatTile(value: '${all.length}', label: 'Total'),
                StatTile(value: '$upcomingCount', label: 'Upcoming', accent: true),
                StatTile(
                  value: '${all.where((b) => b.status == BookingStatus.completed).length}',
                  label: 'Completed',
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = f == _filter;
                return ChoiceChip(
                  label: Text(f),
                  selected: selected,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.white : AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _filter = f),
                );
              },
            ),
          ),
          if (children.length > 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                itemCount: children.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final name = i == 0 ? 'All children' : children[i - 1].name;
                  final selected = name == _child;
                  return ChoiceChip(
                    label: Text(name),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppColors.yellow,
                    labelStyle: TextStyle(
                      color: AppColors.navy,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) => setState(() => _child = name),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? EmptyState(
                    icon: Icons.event_busy_rounded,
                    title: all.isEmpty ? 'No bookings yet' : 'Nothing here',
                    message: all.isEmpty
                        ? (isTutor
                            ? 'Sessions booked with you will appear here.'
                            : 'Find a tutor and book the first lesson.')
                        : 'No lessons match this filter.',
                    action: (all.isEmpty && !isTutor)
                        ? ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FindTutorsScreen()),
                            ),
                            child: const Text('Find a tutor'),
                          )
                        : null,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _BookingCard(
                      booking: list[i],
                      isTutor: isTutor,
                      countdown: _countdown(list[i].start),
                      onCancel: () => _cancel(list[i]),
                      onReschedule: () => _reschedule(list[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.isTutor,
    required this.countdown,
    required this.onCancel,
    required this.onReschedule,
  });

  final Booking booking;
  final bool isTutor;
  final String countdown;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final upcoming = status == BookingStatus.upcoming;

    final chip = switch (status) {
      BookingStatus.upcoming => const StatusChip('Upcoming', tone: ChipTone.solid),
      BookingStatus.completed => const StatusChip('Completed'),
      BookingStatus.cancelled => const StatusChip('Cancelled', tone: ChipTone.neutral),
    };

    final who = isTutor ? booking.learnerName : booking.tutorName;
    final initials = who.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(initials.isEmpty ? '?' : initials, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.subject,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTutor
                          ? 'Learner: ${booking.learnerName}'
                          : '${booking.tutorName}  |  for ${booking.learnerName}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              chip,
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.blue),
              const SizedBox(width: 6),
              Text(formatDate(booking.start), style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, size: 15, color: AppColors.blue),
              const SizedBox(width: 6),
              Text(formatRange(booking), style: const TextStyle(fontSize: 13)),
              const Spacer(),
              Text(
                'R${booking.price}',
                style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if (upcoming) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.yellowSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.navy),
                  const SizedBox(width: 6),
                  Text(
                    countdown,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
            if (!isTutor) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReschedule,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42)),
                      child: const Text('Reschedule'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        minimumSize: const Size(0, 42),
                      ),
                      child: const Text('Cancel lesson'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
