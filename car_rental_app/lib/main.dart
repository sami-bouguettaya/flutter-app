import 'package:flutter/material.dart';
import 'package:car_rental_app/theme/app_theme.dart';
import 'package:car_rental_app/screens/home_screen.dart';
import 'package:car_rental_app/screens/login_screen.dart';
import 'package:car_rental_app/screens/main_screen.dart';
import 'package:car_rental_app/screens/register_screen.dart';
import 'package:car_rental_app/screens/add_car_screen.dart';
import 'package:car_rental_app/screens/profile_screen.dart';
import 'package:car_rental_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getString('user_data') != null;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarShare',
      theme: AppTheme.lightTheme,
      initialRoute: isLoggedIn ? '/main' : '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final initialTab = args?['tab'] ?? 0;
          return MainScreen(initialTabIndex: initialTab);
        },
        '/add-car': (context) => const AddCarScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
