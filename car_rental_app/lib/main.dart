import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/theme/app_theme.dart';
import 'package:car_rental_app/screens/home_screen.dart';
import 'package:car_rental_app/screens/login_screen.dart';
import 'package:car_rental_app/screens/main_screen.dart';
import 'package:car_rental_app/screens/register_screen.dart';
import 'package:car_rental_app/screens/add_car_screen.dart';
import 'package:car_rental_app/screens/profile_screen.dart';
import 'package:car_rental_app/screens/admin_cars_screen.dart';
import 'package:car_rental_app/services/auth_service.dart';
import 'package:car_rental_app/providers/auth_provider.dart';
import 'package:car_rental_app/services/car_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs);
  final carService = CarService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        Provider<CarService>(
          create: (_) => carService,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarShare',
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return authProvider.isAuthenticated
              ? const MainScreen()
              : const HomeScreen();
        },
      ),
      routes: {
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
        '/admin/cars': (context) => const AdminCarsScreen(),
      },
    );
  }
}
