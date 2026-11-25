/// Curriculum helpers: Grades R to 12, split into primary and high school.
const List<String> kGrades = [
  'Grade R',
  'Grade 1',
  'Grade 2',
  'Grade 3',
  'Grade 4',
  'Grade 5',
  'Grade 6',
  'Grade 7',
  'Grade 8',
  'Grade 9',
  'Grade 10',
  'Grade 11',
  'Grade 12',
];

const List<String> kPrimarySubjects = [
  'Mathematics',
  'Reading',
  'Spelling',
  'Life Skills',
];

const List<String> kHighSchoolSubjects = [
  'Mathematics',
  'Physical Sciences',
  'Life Sciences',
  'Accounting',
  'Geography',
  'English',
];

/// Grade R is 0. Understands labels such as "Grade 3", "Grade R" or "R".
int? gradeNumber(String? grade) {
  if (grade == null) return null;
  final t = grade.trim().toLowerCase();
  if (t.isEmpty) return null;
  if (t == 'grade r' || t == 'r') return 0;
  final m = RegExp(r'\d+').firstMatch(t);
  return m == null ? null : int.parse(m.group(0)!);
}

/// Grade R to 7 is primary school, 8 to 12 is high school.
bool isPrimaryGrade(String? grade) {
  final n = gradeNumber(grade);
  return n != null && n <= 7;
}

List<String> subjectsForGrade(String? grade) =>
    isPrimaryGrade(grade) ? kPrimarySubjects : kHighSchoolSubjects;

class Tutor {
  const Tutor({
    required this.id,
    required this.name,
    required this.subject,
    required this.minGrade,
    required this.maxGrade,
    required this.rating,
    required this.reviews,
    required this.pricePerHour,
    required this.students,
    required this.bio,
    this.badge,
  });

  final String id;
  final String name;
  final String subject;
  final int minGrade; // Grade R is 0
  final int maxGrade;
  final double rating;
  final int reviews;
  final int pricePerHour;
  final int students;
  final String bio;
  final String? badge;

  bool teachesGrade(int grade) => grade >= minGrade && grade <= maxGrade;

  String get gradesLabel {
    if (minGrade == maxGrade) return minGrade == 0 ? 'Grade R' : 'Grade $minGrade';
    return minGrade == 0 ? 'Grade R to $maxGrade' : 'Grades $minGrade to $maxGrade';
  }

  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  String get priceLabel => 'R$pricePerHour/hr';
}

/// Sample catalogue. Replace with a backend call (Firebase, Supabase or your
/// own API) once tutors can register, verify and publish their profiles.
const List<Tutor> kTutors = [
  Tutor(
    id: 'T001',
    name: 'Ms Dlamini',
    subject: 'Mathematics',
    minGrade: 8,
    maxGrade: 12,
    rating: 4.9,
    reviews: 127,
    pricePerHour: 150,
    students: 45,
    badge: 'Top Rated',
    bio: 'Mathematics specialist with 9 years of classroom experience and exam focused revision.',
  ),
  Tutor(
    id: 'T006',
    name: 'Mr Khoza',
    subject: 'Mathematics',
    minGrade: 10,
    maxGrade: 12,
    rating: 4.7,
    reviews: 41,
    pricePerHour: 130,
    students: 22,
    badge: 'New',
    bio: 'Works through past papers step by step until the method feels natural.',
  ),
  Tutor(
    id: 'T002',
    name: 'Mr Nkosi',
    subject: 'Physical Sciences',
    minGrade: 10,
    maxGrade: 12,
    rating: 4.8,
    reviews: 96,
    pricePerHour: 180,
    students: 38,
    badge: 'Popular',
    bio: 'Makes physics and chemistry practical, with exam focused revision plans.',
  ),
  Tutor(
    id: 'T005',
    name: 'Mrs Khumalo',
    subject: 'Life Sciences',
    minGrade: 10,
    maxGrade: 12,
    rating: 4.8,
    reviews: 73,
    pricePerHour: 150,
    students: 34,
    bio: 'Clear, diagram based Life Sciences lessons that build exam confidence.',
  ),
  Tutor(
    id: 'T003',
    name: 'Ms Patel',
    subject: 'Accounting',
    minGrade: 10,
    maxGrade: 12,
    rating: 4.7,
    reviews: 84,
    pricePerHour: 160,
    students: 52,
    badge: 'Expert',
    bio: 'Chartered accountant who tutors Accounting and Business Studies.',
  ),
  Tutor(
    id: 'T010',
    name: 'Ms Mokoena',
    subject: 'Geography',
    minGrade: 8,
    maxGrade: 12,
    rating: 4.6,
    reviews: 33,
    pricePerHour: 140,
    students: 18,
    bio: 'Map work, climate and settlement topics explained with real examples.',
  ),
  Tutor(
    id: 'T004',
    name: 'Mr Williams',
    subject: 'English',
    minGrade: 8,
    maxGrade: 12,
    rating: 4.6,
    reviews: 61,
    pricePerHour: 140,
    students: 30,
    bio: 'Essay writing, comprehension and literature support for high school.',
  ),
  Tutor(
    id: 'T007',
    name: 'Mrs Naidoo',
    subject: 'Mathematics',
    minGrade: 1,
    maxGrade: 7,
    rating: 4.9,
    reviews: 88,
    pricePerHour: 120,
    students: 40,
    badge: 'Top Rated',
    bio: 'Patient, playful maths lessons that build number confidence early.',
  ),
  Tutor(
    id: 'T008',
    name: 'Ms Baloyi',
    subject: 'Reading',
    minGrade: 0,
    maxGrade: 7,
    rating: 4.8,
    reviews: 52,
    pricePerHour: 110,
    students: 29,
    bio: 'Phonics, story time and reading fluency in short, fun sessions.',
  ),
  Tutor(
    id: 'T009',
    name: 'Mr Sithole',
    subject: 'Spelling',
    minGrade: 1,
    maxGrade: 7,
    rating: 4.7,
    reviews: 37,
    pricePerHour: 100,
    students: 21,
    bio: 'Spelling games and word patterns that make words stick.',
  ),
  Tutor(
    id: 'T011',
    name: 'Ms Zulu',
    subject: 'Life Skills',
    minGrade: 0,
    maxGrade: 7,
    rating: 4.6,
    reviews: 24,
    pricePerHour: 100,
    students: 15,
    bio: 'Creative, hands on Life Skills support for young learners.',
  ),
];
