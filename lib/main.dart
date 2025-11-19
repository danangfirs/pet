import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_page.dart';
import 'services/theme_service.dart';

void main() {
  runApp(const RaptorCApp());
}

class RaptorCApp extends StatefulWidget {
  const RaptorCApp({Key? key}) : super(key: key);

  @override
  State<RaptorCApp> createState() => _RaptorCAppState();
}

class _RaptorCAppState extends State<RaptorCApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      _themeService.isDarkMode 
        ? SystemUiOverlayStyle.light 
        : SystemUiOverlayStyle.dark
    );
    
    return MaterialApp(
      title: 'RaptorC',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF00F5D4),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Poppins',
        cardColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF212121)),
          bodyMedium: TextStyle(color: Color(0xFF757575)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF212121)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF212121)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
      ),
      darkTheme: ThemeData(
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
      themeMode: _themeService.themeMode,
      debugShowCheckedModeBanner: false,
      home: LoginPage(themeService: _themeService),
    );
  }
}

