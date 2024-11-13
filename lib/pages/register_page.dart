import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koda/helper/constant.dart';
import 'package:koda/pages/login_page.dart';
import 'package:koda/pages/main_page.dart';
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

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(() {
      setState(() {
        emailFocus = emailFocusNode.hasFocus;
      });
    });
    passwordFocusNode.addListener(() {
      setState(() {
        passwordFocus = passwordFocusNode.hasFocus;
      });
    });
    confirmPasswordFocusNode.addListener(() {
      setState(() {
        confirmPasswordFocus = confirmPasswordFocusNode.hasFocus;
      });
    });
  }

  Future<void> registerUser() async {
    if (emailController.text.isEmpty) {
      setState(() {
        errorEmailText = "Email is required";
      });
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        errorPasswordText = "Password is required";
      });
    }

    if (confirmPasswordController.text.isEmpty) {
      setState(() {
        errorConfirmPasswordText = "Confirm is required";
      });
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorConfirmPasswordText = "Password does not match";
      });
    }

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
                TextFormField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  onChanged: (value) {
                    setState(() {
                      errorEmailText = null;
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    label: const Text("Email"),
                    labelStyle: TextStyle(
                      color: emailFocus && errorEmailText == null
                          ? Colors.black
                          : null,
                      fontWeight: emailFocus && errorEmailText == null
                          ? FontWeight.bold
                          : null,
                    ),
                    errorText: errorEmailText,
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: const Icon(Icons.email),
                    prefixIconColor: errorEmailText != null ? Colors.red : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  onChanged: (value) {
                    setState(() {
                      errorPasswordText = null;
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    label: const Text("Password"),
                    labelStyle: TextStyle(
                      color: passwordFocus && errorPasswordText == null
                          ? Colors.black
                          : null,
                      fontWeight: passwordFocus && errorPasswordText == null
                          ? FontWeight.bold
                          : null,
                    ),
                    errorText: errorPasswordText,
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    suffixIcon: IconButton(
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
                    prefixIcon: const Icon(Icons.lock),
                    prefixIconColor:
                        errorPasswordText != null ? Colors.red : null,
                  ),
                  obscureText: !showPasswordText,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  onChanged: (value) {
                    setState(() {
                      errorConfirmPasswordText = null;
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    label: const Text("Confirm Password"),
                    labelStyle: TextStyle(
                      color:
                          confirmPasswordFocus && errorConfirmPasswordText == null
                              ? Colors.black
                              : null,
                      fontWeight:
                          confirmPasswordFocus && errorConfirmPasswordText == null
                              ? FontWeight.bold
                              : null,
                    ),
                    errorText: errorConfirmPasswordText,
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    suffixIcon: IconButton(
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
                    prefixIcon: const Icon(Icons.lock),
                    prefixIconColor:
                        errorConfirmPasswordText != null ? Colors.red : null,
                  ),
                  obscureText: !showConfirmPasswordText,
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
                      style: TextButton.styleFrom(foregroundColor: Colors.black),
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
