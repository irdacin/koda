import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:koda/pages/auth/login_page.dart';
import 'package:koda/pages/home/main_page.dart';
import 'package:koda/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(KEY_LOGGED_IN) ?? false;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? const MainPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          context.watch<ThemeProvider>().themeMode == ThemeMode.light
              ? Colors.white
              : context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                  ? Colors.black
                  : null,
      body: const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }
}
