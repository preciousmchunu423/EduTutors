import 'package:flutter/foundation.dart';
import '../models/tutor_workspace.dart';
import '../repositories/tutor_repository.dart';

class TutorViewModel extends ChangeNotifier {
  TutorViewModel(this._repository);
  final TutorRepository _repository;
  TutorWorkspace _workspace = TutorWorkspace();
  String? _email;
  bool _ready = false;
  TutorWorkspace get workspace => _workspace;
  bool get isReady => _ready;

  Future<void> loadFor(String? email) async {
    if (email == null || email.isEmpty) return;
    if (_email == email && _ready) return;
    _email = email;
    _ready = false;
    notifyListeners();
    _workspace = await _repository.load(email);
    _ready = true;
    notifyListeners();
  }
  Future<void> _save(TutorWorkspace next) async {
    _workspace = next;
    final email = _email;
    if (email != null) await _repository.save(email, next);
    notifyListeners();
  }
  Future<void> updateProfile({required String bio, required String qualifications, required List<String> subjects, required int hourlyRate}) => _save(TutorWorkspace(bio: bio, qualifications: qualifications, subjects: subjects, hourlyRate: hourlyRate, availableDays: _workspace.availableDays, startTime: _workspace.startTime, endTime: _workspace.endTime, content: _workspace.content));
  Future<void> updateAvailability({required List<String> days, required String start, required String end}) => _save(TutorWorkspace(bio: _workspace.bio, qualifications: _workspace.qualifications, subjects: _workspace.subjects, hourlyRate: _workspace.hourlyRate, availableDays: days, startTime: start, endTime: end, content: _workspace.content));
  Future<void> addContent({required String title, required String subject, required String type, required String resourceUrl}) {
    final item = TutorContent(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title, subject: subject, type: type, resourceUrl: resourceUrl);
    return _save(TutorWorkspace(bio: _workspace.bio, qualifications: _workspace.qualifications, subjects: _workspace.subjects, hourlyRate: _workspace.hourlyRate, availableDays: _workspace.availableDays, startTime: _workspace.startTime, endTime: _workspace.endTime, content: [..._workspace.content, item]));
  }
  Future<void> removeContent(String id) => _save(TutorWorkspace(bio: _workspace.bio, qualifications: _workspace.qualifications, subjects: _workspace.subjects, hourlyRate: _workspace.hourlyRate, availableDays: _workspace.availableDays, startTime: _workspace.startTime, endTime: _workspace.endTime, content: _workspace.content.where((e) => e.id != id).toList()));
}
