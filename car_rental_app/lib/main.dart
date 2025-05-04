import 'package:flutter/material.dart';
import 'package:car_rental_app/theme/app_theme.dart';
import 'package:car_rental_app/screens/home_screen.dart';
import 'package:car_rental_app/screens/login_screen.dart';
import 'package:car_rental_app/screens/main_screen.dart';
import 'package:car_rental_app/screens/register_screen.dart';
import 'package:car_rental_app/screens/add_car_screen.dart';
import 'package:car_rental_app/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarShare',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final initialTab = args?['tab'] ?? 0;
          return MainScreen(initialTabIndex: initialTab);
        },
        '/add-car': (context) => const AddCarScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
