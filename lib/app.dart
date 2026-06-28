import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';

class GreenBasketApp extends StatelessWidget {
  const GreenBasketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Basket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
