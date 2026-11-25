import 'package:flutter/material.dart';

import '../../models/booking.dart';
import 'package:provider/provider.dart';
import '../widgets/common_widgets.dart';
import '../../data/tutors_data.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/booking_view_model.dart';
import '../../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/custom_button.dart';

/// Parents can message the tutors their children already work with.
/// NOTE: sending is a placeholder until a chat or notification backend exists.
class ContactTutorScreen extends StatefulWidget {
  const ContactTutorScreen({super.key});

  @override
  State<ContactTutorScreen> createState() => _ContactTutorScreenState();
}

class _ContactTutorScreenState extends State<ContactTutorScreen> {
  final _message = TextEditingController();
  String? _tutorId;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _send(Tutor tutor) {
    if (_message.text.trim().isEmpty) {
      showAppSnack(context, 'Please write a message first.', warning: true);
      return;
    }
    showAppSnack(context, 'Message sent to ${tutor.name}.');
    _message.clear();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final bookings = context.watch<BookingViewModel>().forOwner(auth.userEmail);

    // Tutors this family already books, falling back to everyone.
    final bookedIds = bookings.map((b) => b.tutorId).toSet();
    final tutors = bookedIds.isEmpty
        ? kTutors
        : kTutors.where((t) => bookedIds.contains(t.id)).toList();

    final selected = tutors.firstWhere(
      (t) => t.id == _tutorId,
      orElse: () => tutors.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Contact a tutor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('Choose a tutor'),
          const SizedBox(height: 12),
          for (final t in tutors)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _tutorId = t.id),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t.id == selected.id ? AppColors.blueSoft : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: t.id == selected.id ? AppColors.blue : AppColors.border,
                      width: t.id == selected.id ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      InitialsAvatar(t.initials, size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(t.subject,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (t.id == selected.id)
                        const Icon(Icons.check_circle_rounded, color: AppColors.blue),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const SectionTitle('Message'),
          const SizedBox(height: 12),
          TextField(
            controller: _message,
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Write to ${selected.name}...',
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Send message',
            icon: Icons.send_rounded,
            onPressed: () => _send(selected),
          ),
        ],
      ),
    );
  }
}
