import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:koda/pages/auth/widget/input_field.dart';
import 'package:koda/pages/home/home_page.dart';
import 'package:koda/pages/auth/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  bool emailFocus = false;
  bool passwordFocus = false;
  bool showPasswordText = false;
  String? errorText;

  Future<void> loginUser() async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(KEY_LOGGED_IN, true);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (_) {
      setState(() {
        errorText = "Invalid email or password";
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
                    "LOGIN",
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
                  labelText: "Password",
                  icon: Icons.lock,
                  errorText: errorText,
                  isVisible: showPasswordText,
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
                ),
                const SizedBox(height: 20),
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
                    child: const Text("LOGIN"),
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      "Don't have an account?",
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("REGISTER"),
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
