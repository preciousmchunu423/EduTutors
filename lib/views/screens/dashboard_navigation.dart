import 'package:flutter/material.dart';

import 'dashboards/learner_dashboard.dart';
import 'dashboards/parent_dashboard.dart';
import 'dashboards/tutor_dashboard.dart';

/// Single place that maps a role to its home screen.
Widget dashboardForRole(String? role) {
  switch (role) {
    case 'Parent':
      return const ParentDashboard();
    case 'Tutor':
      return const TutorDashboard();
    case 'Learner':
    default:
      return const LearnerDashboard();
  }
}
