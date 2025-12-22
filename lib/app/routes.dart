import '../features/auth/login_screen.dart';
import '../features/screens/home_screen.dart';

class AppRoutes {
  static final routes = {
    '/': (_) => const HomeScreen(),
    '/login': (_) => const LoginScreen(),
  };
}
