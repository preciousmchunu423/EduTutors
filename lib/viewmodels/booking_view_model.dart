import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../repositories/booking_repository.dart';

class BookingViewModel extends ChangeNotifier {
  final List<Booking> _all = [];
  bool _ready = false;

  BookingViewModel(this._repository) {
    _load();
  }

  final BookingRepository _repository;

  bool get isReady => _ready;

  Future<void> _load() async {
    _all
      ..clear()
      ..addAll(await _repository.loadBookings());
    _ready = true;
    notifyListeners();
  }

  Future<void> _save() => _repository.saveBookings(_all);

  List<Booking> forOwner(String? email) {
    if (email == null) return const [];
    final list = _all.where((b) => b.ownerEmail == email).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  List<Booking> forTutor(String? name) {
    if (name == null) return const [];
    final list = _all.where((b) => b.tutorName == name).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  /// True when the same tutor already has a live booking at this time.
  bool isSlotTaken(String tutorId, DateTime start, {String? ignoreId}) {
    return _all.any((b) =>
        b.id != ignoreId &&
        !b.cancelled &&
        b.tutorId == tutorId &&
        b.start == start);
  }

  Future<void> add(Booking booking) async {
    _all.add(booking);
    await _save();
    notifyListeners();
  }

  Future<void> cancel(String id) async {
    for (final b in _all) {
      if (b.id == id) b.cancelled = true;
    }
    await _save();
    notifyListeners();
  }

  Future<void> reschedule(String id, DateTime newStart) async {
    for (final b in _all) {
      if (b.id == id) b.start = newStart;
    }
    await _save();
    notifyListeners();
  }

  EngagementSummary engagementFor(String ownerEmail, String learnerName) {
    final mine = _all
        .where((b) => b.ownerEmail == ownerEmail && b.learnerName == learnerName)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final done = mine.where((b) => b.status == BookingStatus.completed).toList();
    final upcoming = mine.where((b) => b.status == BookingStatus.upcoming).toList();
    final cancelled = mine.where((b) => b.status == BookingStatus.cancelled).length;

    final subjects = <String, int>{};
    for (final b in done) {
      subjects[b.subject] = (subjects[b.subject] ?? 0) + 1;
    }

    return EngagementSummary(
      completed: done.length,
      upcoming: upcoming.length,
      cancelled: cancelled,
      hoursLearned: done.length,
      subjects: subjects,
      lastSession: done.isEmpty ? null : done.last,
      nextSession: upcoming.isEmpty ? null : upcoming.first,
    );
  }
}

