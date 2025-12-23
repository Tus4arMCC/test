import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/main/main_tab_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/cache/cache_manager.dart';
import 'app/routes.dart';

// 🔥 IMPORT MODELS
import 'features/product/models/product_model.dart';
import 'features/product/models/product_tag_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();

  // ✅ REGISTER HIVE ADAPTERS
  Hive.registerAdapter(ProductImageAdapter());
  Hive.registerAdapter(ProductTagAdapter());
  Hive.registerAdapter(ProductAdapter());

  await CacheManager.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          routes: AppRoutes.routes,
          home: const MainTabScreen(),
        );
      },
    );
  }
}
