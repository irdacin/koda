import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:koda/pages/auth/login_page.dart';
import 'package:koda/components/input_field.dart';
import 'package:koda/pages/intro/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  bool emailFocus = false;
  bool passwordFocus = false;
  bool confirmPasswordFocus = false;
  bool showPasswordText = false;
  bool showConfirmPasswordText = false;
  String? errorEmailText;
  String? errorPasswordText;
  String? errorConfirmPasswordText;

  Future<void> registerUser() async {
    setState(() {
      if (emailController.text.isEmpty) {
        errorEmailText = "Email is required";
      }

      if (passwordController.text.isEmpty) {
        errorPasswordText = "Password is required";
      }

      if (confirmPasswordController.text.isEmpty) {
        errorConfirmPasswordText = "Confirm Password is required";
      }

      if (passwordController.text != confirmPasswordController.text) {
        errorConfirmPasswordText = "Password does not match";
      }
    });

    if (errorEmailText != null ||
        errorPasswordText != null ||
        errorConfirmPasswordText != null) {
      return;
    }

    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      await firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(KEY_LOGGED_IN, true);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == "weak-password") {
          errorPasswordText = "Password is too weak";
        } else if (e.code == "email-already-in-use") {
          errorEmailText = "Email already in use";
        } else if (e.code == "invalid-email") {
          errorEmailText = "Email is not valid";
        }
      });
    }
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
                const Center(
                  child: Text(
                    "REGISTER",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                InputField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  labelText: "Email",
                  icon: Icons.email,
                  errorText: errorEmailText,
                  onChanged: (value) {
                    setState(() {
                      errorEmailText = null;
                    });
                  },
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  onChanged: (value) {
                    setState(() {
                      errorPasswordText = null;
                    });
                  },
                  labelText: "Password",
                  errorText: errorPasswordText,
                  icon: Icons.lock,
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        showPasswordText ^= true;
                      });
                    },
                    icon: Icon(
                      showPasswordText
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  isVisible: showPasswordText,
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  onChanged: (value) {
                    setState(() {
                      errorConfirmPasswordText = null;
                    });
                  },
                  labelText: "Confirm Passsword",
                  errorText: errorConfirmPasswordText,
                  icon: Icons.lock,
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        showConfirmPasswordText ^= true;
                      });
                    },
                    icon: Icon(
                      showConfirmPasswordText
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  isVisible: showConfirmPasswordText,
                ),
                const SizedBox(height: 20),
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
                    child: const Text("REGISTER"),
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      "Already have an account?",
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("LOGIN"),
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
}
