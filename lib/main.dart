
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'viewmodels/auth_view_model.dart';
import 'repositories/auth_repository.dart';
import 'viewmodels/booking_view_model.dart';
import 'repositories/booking_repository.dart';
import 'repositories/tutor_repository.dart';
import 'viewmodels/tutor_view_model.dart';
import 'views/screens/dashboard_navigation.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/register_screen.dart';
import 'views/screens/welcome_screen.dart';
import 'views/screens/admin/admin_dashboard.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oxnpzxhlfashezqjoeiq.supabase.co',
    publishableKey: 'sb_publishable_NRgahiWdfaBXgsXHi3zt_A_2-5WoNEZ',
  );

  runApp(const EduTutorsApp());
}

class EduTutorsApp extends StatelessWidget {
  const EduTutorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(AuthRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingViewModel(BookingRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => TutorViewModel(TutorRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EduTutors',
        theme: AppTheme.light,
        home: const _AppRoot(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
        },
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    if (!auth.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.isLoggedIn) {
      if (auth.isOrgAdmin) return const AdminDashboard();
      return dashboardForRole(auth.userRole);
    }

    return const WelcomeScreen();
  }
}
