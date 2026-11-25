/// Booking domain models and display-formatting helpers.

enum BookingStatus { upcoming, completed, cancelled }

class Booking {
  Booking({
    required this.id,
    required this.ownerEmail,
    required this.learnerName,
    required this.tutorId,
    required this.tutorName,
    required this.subject,
    required this.start,
    required this.price,
    this.cancelled = false,
  });

  final String id;
  final String ownerEmail; // account that made the booking (parent or learner)
  final String learnerName;
  final String tutorId;
  final String tutorName;
  final String subject;
  DateTime start;
  final int price;
  bool cancelled;

  DateTime get end => start.add(const Duration(hours: 1));

  /// A booking whose hour has passed is treated as completed automatically.
  BookingStatus get status {
    if (cancelled) return BookingStatus.cancelled;
    if (end.isBefore(DateTime.now())) return BookingStatus.completed;
    return BookingStatus.upcoming;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerEmail': ownerEmail,
        'learnerName': learnerName,
        'tutorId': tutorId,
        'tutorName': tutorName,
        'subject': subject,
        'start': start.toIso8601String(),
        'price': price,
        'cancelled': cancelled,
      };

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'] as String,
        ownerEmail: j['ownerEmail'] as String,
        learnerName: j['learnerName'] as String,
        tutorId: j['tutorId'] as String,
        tutorName: j['tutorName'] as String,
        subject: j['subject'] as String,
        start: DateTime.parse(j['start'] as String),
        price: j['price'] as int,
        cancelled: (j['cancelled'] as bool?) ?? false,
      );
}

/// What a parent sees when tracking one child.
class EngagementSummary {
  const EngagementSummary({
    required this.completed,
    required this.upcoming,
    required this.cancelled,
    required this.hoursLearned,
    required this.subjects,
    this.lastSession,
    this.nextSession,
  });

  final int completed;
  final int upcoming;
  final int cancelled;
  final int hoursLearned;
  final Map<String, int> subjects; // subject -> sessions attended
  final Booking? lastSession;
  final Booking? nextSession;

  /// Share of finished sessions that were attended rather than cancelled.
  int get attendancePercent {
    final total = completed + cancelled;
    if (total == 0) return 0;
    return (completed * 100 / total).round();
  }
}

String formatDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String formatTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String formatRange(Booking b) => '${formatTime(b.start)} to ${formatTime(b.end)}';
