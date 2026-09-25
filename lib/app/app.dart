import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/screens/splash_screen.dart';

class SocialPostsApp extends StatelessWidget {
  const SocialPostsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Posts',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
