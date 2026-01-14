import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/main/main_tab_screen.dart';
import '../features/order/screens/order_list_screen.dart';
import '../features/order/screens/order_detail_screen.dart';
import '../features/address/screens/address_list_screen.dart';
import '../features/address/screens/address_form_screen.dart';

class AppRoutes {
  static final routes = {
    '/': (_) => const MainTabScreen(),
    '/login': (_) => const LoginScreen(),
    '/orders': (_) => const OrderListScreen(),
    '/order-detail': (_) => const OrderDetailScreen(),
    '/addresses': (_) => const AddressListScreen(),
    '/address-form': (_) => const AddressFormScreen(),
    '/register': (_) => const RegisterScreen(),
  };
}
