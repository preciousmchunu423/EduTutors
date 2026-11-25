/// Data models for EduTutors accounts and parent-linked learners.
class Child {
  const Child({
    required this.id,
    required this.name,
    required this.grade,
    this.subjects = const [],
  });

  final String id;
  final String name;
  final String grade;
  final List<String> subjects;

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'grade': grade, 'subjects': subjects};

  factory Child.fromJson(Map<String, dynamic> json) => Child(
        id: json['id'] as String,
        name: json['name'] as String,
        grade: (json['grade'] as String?) ?? '',
        subjects: ((json['subjects'] as List?) ?? []).map((e) => e as String).toList(),
      );
}

class UserAccount {
  UserAccount({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.parentEmail,
    this.grade,
    this.subjects = const [],
    List<Child>? children,
  }) : children = children ?? [];

  final String name;
  final String email;
  final String passwordHash;
  final String role; // Learner, Parent or Tutor
  final String? parentEmail; // set when a learner links to a parent
  final String? grade;
  final List<String> subjects; // learner's chosen subjects
  final List<Child> children; // used by parents

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'role': role,
        'parentEmail': parentEmail,
        'grade': grade,
        'subjects': subjects,
        'children': children.map((c) => c.toJson()).toList(),
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        name: json['name'] as String,
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
        role: json['role'] as String,
        parentEmail: json['parentEmail'] as String?,
        grade: json['grade'] as String?,
        subjects: ((json['subjects'] as List?) ?? []).map((e) => e as String).toList(),
        children: ((json['children'] as List?) ?? [])
            .map((c) => Child.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList(),
      );
}

