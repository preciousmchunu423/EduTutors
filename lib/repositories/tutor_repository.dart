import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tutor_workspace.dart';

class TutorRepository {
  String _key(String email) => 'tutor_workspace_${email.toLowerCase()}';
  Future<TutorWorkspace> load(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(email));
    if (raw == null) return TutorWorkspace();
    try { return TutorWorkspace.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map)); }
    catch (_) { return TutorWorkspace(); }
  }
  Future<void> save(String email, TutorWorkspace workspace) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(email), jsonEncode(workspace.toJson()));
  }
}
