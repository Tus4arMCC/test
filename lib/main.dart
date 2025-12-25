import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/product/models/product_model.dart';
import 'features/product/models/product_tag_model.dart';
import 'features/product/models/product_image_model.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/cache/cache_manager.dart';
import 'app/routes.dart';

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
        final currentTheme = mode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          builder: (context, child) {
            // High-end liquid transition:
            // Combination of Cross-Fade and smooth Theme interpolation
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: AnimatedTheme(
                key: ValueKey(mode), 
                data: currentTheme,
                // Synchronized duration for a cohesive "liquid" color Morph
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOutCubic,
                child: child!,
              ),
            );
          },
          routes: AppRoutes.routes,
          initialRoute: '/',
        );
      },
    );
  }
}
