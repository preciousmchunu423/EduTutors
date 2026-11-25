import 'package:flutter/material.dart';

IconData subjectIcon(String subject) {
  switch (subject) {
    case 'Mathematics':
      return Icons.calculate_rounded;
    case 'Physical Sciences':
      return Icons.science_rounded;
    case 'Life Sciences':
      return Icons.biotech_rounded;
    case 'Accounting':
      return Icons.receipt_long_rounded;
    case 'Geography':
      return Icons.public_rounded;
    case 'English':
      return Icons.menu_book_rounded;
    case 'Reading':
      return Icons.auto_stories_rounded;
    case 'Spelling':
      return Icons.abc_rounded;
    case 'Life Skills':
      return Icons.favorite_rounded;
    default:
      return Icons.school_rounded;
  }
}
