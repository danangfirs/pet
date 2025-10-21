import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const RaptorCApp());
}

class RaptorCApp extends StatelessWidget {
  const RaptorCApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MaterialApp(
      title: 'RaptorC',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00F5D4),
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Poppins',
        cardColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
          bodyMedium: TextStyle(color: Color(0xFFB0B0B0)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

