import 'package:flutter/material.dart';

import '../../models/booking.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/booking_view_model.dart';
import '../../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// Lesson costs for the logged in parent or learner, built from real bookings.
/// NOTE: no payment gateway is connected yet, so this is a statement of what
/// has been booked rather than a record of money received.
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final all = context.watch<BookingViewModel>().forOwner(auth.userEmail);
    final items = all.reversed.toList();

    final active = all.where((b) => b.status != BookingStatus.cancelled);
    final totalBooked = active.fold<int>(0, (sum, b) => sum + b.price);
    final upcomingTotal = all
        .where((b) => b.status == BookingStatus.upcoming)
        .fold<int>(0, (sum, b) => sum + b.price);

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total booked',
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'R $totalBooked.00',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Upcoming lessons: R $upcomingTotal.00',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppDecor.card(color: AppColors.blueSoft, outlined: false),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: AppColors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Online payments are coming soon. Lessons are currently settled directly with the tutor.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Lesson history'),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No lessons yet',
                message: 'Booked lessons and their costs will be listed here.',
              ),
            )
          else
            for (final b in items)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: AppDecor.card(),
                child: Row(
                  children: [
                    const IconBadge(Icons.receipt_long_rounded, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${b.subject} with ${b.tutorName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${b.learnerName}  |  ${formatDate(b.start)}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'R${b.price}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: b.status == BookingStatus.cancelled
                                ? AppColors.textMuted
                                : AppColors.blue,
                            decoration: b.status == BookingStatus.cancelled
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        switch (b.status) {
                          BookingStatus.upcoming =>
                            const StatusChip('Upcoming', tone: ChipTone.yellow),
                          BookingStatus.completed => const StatusChip('Completed'),
                          BookingStatus.cancelled =>
                            const StatusChip('Cancelled', tone: ChipTone.neutral),
                        },
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
