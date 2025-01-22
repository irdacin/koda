import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:koda/pages/auth/login_page.dart';
import 'package:koda/pages/home/main_page.dart';
import 'package:koda/pages/home/onboarding_page.dart';
import 'package:koda/providers/theme_provider.dart';
import 'package:koda/utils/app_colors.dart';
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
    final isLoggedIn = prefs.getBool(KEY_LOGGED_IN);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => isLoggedIn == null ? const OnboardingPage() : isLoggedIn ? const MainPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppColors.updateTheme(
      context.watch<ThemeProvider>().themeMode == ThemeMode.system
          ? Theme.of(context).brightness == Brightness.dark
          : null,
    );

    return Scaffold(
      backgroundColor:
          context.watch<ThemeProvider>().themeMode == ThemeMode.light
              ? AppColors.lightBackground
              : context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                  ? AppColors.darkBackground
                  : null,
      body: const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }
}
