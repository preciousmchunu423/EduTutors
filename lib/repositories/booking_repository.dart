import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';

/// Handles reading and writing bookings to local device storage.
class BookingRepository {
  static const _key = 'bookings_v1';

  Future<List<Booking>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((item) => Booking.fromJson(
        Map<String, dynamic>.from(item as Map),
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBookings(List<Booking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(bookings.map((booking) => booking.toJson()).toList()),
    );
  }
}
