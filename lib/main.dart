import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_with_api/screen/home_screen.dart';
import 'package:login_with_api/screen/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  /// Check if user is logged in
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getString('user_email') != null;
  
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
