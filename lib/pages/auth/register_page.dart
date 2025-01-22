import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koda/pages/auth/login_page.dart';
import 'package:koda/components/input_field.dart';
import 'package:koda/pages/home/main_page.dart';
import 'package:koda/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final _authService = AuthService();

  bool _showPasswordText = false;
  bool _showConfirmPasswordText = false;
  bool _isLoading = false;
  String? _errorEmailText;
  String? _errorPasswordText;
  String? _errorConfirmPasswordText;

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                  AppLocalizations.of(context)!.createAnAccount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.detailRegister,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                InputField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  labelText: AppLocalizations.of(context)!.email,
                  icon: Icons.email,
                  errorText: _errorEmailText,
                  onChanged: (value) {
                    setState(() {
                      _errorEmailText = null;
                    });
                  },
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _errorPasswordText = null;
                    });
                  },
                  labelText: AppLocalizations.of(context)!.password,
                  errorText: _errorPasswordText,
                  icon: Icons.lock,
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
                  isVisible: _showPasswordText,
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _errorConfirmPasswordText = null;
                    });
                  },
                  labelText: AppLocalizations.of(context)!.confirmPassword,
                  errorText: _errorConfirmPasswordText,
                  icon: Icons.lock,
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        _showConfirmPasswordText ^= true;
                      });
                    },
                    icon: Icon(
                      _showConfirmPasswordText
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  isVisible: _showConfirmPasswordText,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: registerUser,
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
                        : Text(AppLocalizations.of(context)!
                            .register
                            .toUpperCase()),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.alreadyHaveAnAccount,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.login.toUpperCase(),
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

  Future<void> registerUser() async {
    setState(() {
      _isLoading = true;
      if (emailController.text.isEmpty) {
        _errorEmailText = AppLocalizations.of(context)!.emailIsRequired;
      }

      if (passwordController.text.isEmpty) {
        _errorPasswordText = AppLocalizations.of(context)!.passwordIsRequired;
      }

      if (confirmPasswordController.text.isEmpty) {
        _errorConfirmPasswordText =
            AppLocalizations.of(context)!.confirmPasswordIsRequired;
      }

      if (passwordController.text != confirmPasswordController.text) {
        _errorConfirmPasswordText =
            AppLocalizations.of(context)!.passwordDoesNotMatch;
      }
    });

    if (_errorEmailText != null ||
        _errorPasswordText != null ||
        _errorConfirmPasswordText != null) {
      setState(() => _isLoading = false);

      return;
    }

    String? error = await _authService.register(
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
      if (error == "weak-password") {
        _errorPasswordText = AppLocalizations.of(context)!.passwordIsTooWeak;
      } else if (error == "email-already-in-use") {
        _errorEmailText = AppLocalizations.of(context)!.emailAlreadyInUse;
      } else if (error == "invalid-email") {
        _errorEmailText = AppLocalizations.of(context)!.emailIsNotValid;
      }
    });
  }
}
