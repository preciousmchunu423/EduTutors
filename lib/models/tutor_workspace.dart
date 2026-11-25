class TutorContent {
  const TutorContent({required this.id, required this.title, required this.subject, required this.type, this.resourceUrl = ''});
  final String id;
  final String title;
  final String subject;
  final String type;
  final String resourceUrl;
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'subject': subject, 'type': type, 'resourceUrl': resourceUrl};
  factory TutorContent.fromJson(Map<String, dynamic> json) => TutorContent(
    id: json['id'] as String, title: json['title'] as String, subject: json['subject'] as String,
    type: json['type'] as String, resourceUrl: (json['resourceUrl'] as String?) ?? '',
  );
}

class TutorWorkspace {
  TutorWorkspace({this.bio = '', this.qualifications = '', this.subjects = const [], this.hourlyRate = 250, this.availableDays = const ['Monday', 'Wednesday', 'Friday'], this.startTime = '09:00', this.endTime = '17:00', this.content = const []});
  final String bio;
  final String qualifications;
  final List<String> subjects;
  final int hourlyRate;
  final List<String> availableDays;
  final String startTime;
  final String endTime;
  final List<TutorContent> content;
  Map<String, dynamic> toJson() => {'bio': bio, 'qualifications': qualifications, 'subjects': subjects, 'hourlyRate': hourlyRate, 'availableDays': availableDays, 'startTime': startTime, 'endTime': endTime, 'content': content.map((e) => e.toJson()).toList()};
  factory TutorWorkspace.fromJson(Map<String, dynamic> json) => TutorWorkspace(
    bio: (json['bio'] as String?) ?? '', qualifications: (json['qualifications'] as String?) ?? '',
    subjects: ((json['subjects'] as List?) ?? []).cast<String>(), hourlyRate: (json['hourlyRate'] as num?)?.toInt() ?? 250,
    availableDays: ((json['availableDays'] as List?) ?? ['Monday', 'Wednesday', 'Friday']).cast<String>(),
    startTime: (json['startTime'] as String?) ?? '09:00', endTime: (json['endTime'] as String?) ?? '17:00',
    content: ((json['content'] as List?) ?? []).map((e) => TutorContent.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
  );
}
