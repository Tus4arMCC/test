import 'package:flutter/material.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
      debugPrint("HomeScreen loaded");
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
