import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koda/components/input_field.dart';
import 'package:koda/pages/home/main_page.dart';
import 'package:koda/pages/auth/register_page.dart';
import 'package:koda/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _showPasswordText = false;
  String? errorText;

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.login,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.detailLogin,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                InputField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  labelText: AppLocalizations.of(context)!.email,
                  errorText: errorText,
                  icon: Icons.email,
                  onChanged: (value) {
                    setState(() {
                      errorText = null;
                    });
                  },
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  onChanged: (value) {
                    setState(() {
                      errorText = null;
                    });
                  },
                  labelText: AppLocalizations.of(context)!.password,
                  icon: Icons.lock,
                  errorText: errorText,
                  isVisible: _showPasswordText,
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        _showPasswordText ^= true;
                      });
                    },
                    icon: Icon(
                      _showPasswordText
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? Container(
                            width: 22.5,
                            height: 22.5,
                            padding: const EdgeInsets.all(2),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.login.toUpperCase(),
                          ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dontHaveAnAccount,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.register.toUpperCase(),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginUser() async {
    setState(() => _isLoading = true);
    String? error = await _authService.login(
      emailController.text,
      passwordController.text,
    );
    setState(() => _isLoading = false);

    if (error == null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );

      return;
    }

    setState(() {
      errorText = AppLocalizations.of(context)!.invalidEmailOrPassword;
    });
  }
}
