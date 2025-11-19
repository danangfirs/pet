import 'package:flutter/material.dart';
import 'main_screen.dart';
import '../services/theme_service.dart';

class LoginPage extends StatelessWidget {
  final ThemeService themeService;
  const LoginPage({Key? key, required this.themeService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, const Color(0xFF121212)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Icon(Icons.pets, color: theme.primaryColor, size: 60),
                const SizedBox(height: 16),
                const Text('Selamat Datang di RaptorC',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text('Masuk untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.grey[400])),
                const SizedBox(height: 48),
                const TextField(
                    decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon:
                            Icon(Icons.email_outlined, color: Colors.grey)),
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: 'Kata Sandi',
                        prefixIcon:
                            Icon(Icons.lock_outline, color: Colors.grey))),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainScreen(themeService: themeService)));
                  },
                  child: const Text('Masuk',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {},
                        child: Text('Buat Akun Baru',
                            style: TextStyle(color: theme.primaryColor))),
                    TextButton(
                        onPressed: () {},
                        child: const Text('Lupa Kata Sandi?',
                            style: TextStyle(color: Colors.grey))),
                  ],
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
