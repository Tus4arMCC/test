import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/main/main_tab_screen.dart';
import '../features/screens/profile_screen.dart';
import '../features/auth/register_screen.dart';
// import '../features/auth/forgot_password_screen.dart';

class AppRoutes {
  static const login = '/';
  static const main = '/main';
  static const profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    main: (_) => const MainTabScreen(),
    profile: (_) => const ProfileScreen(),
    '/register': (_) => const RegisterScreen(),
    // '/forgot': (_) => const ForgotPasswordScreen(),
  };
}
