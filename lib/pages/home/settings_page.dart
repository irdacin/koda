import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:koda/pages/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> logOutUser() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(KEY_LOGGED_IN, false);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.settings),
                  const SizedBox(width: 20),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              onTap: () {},
              title: const Text("Profile"),
            ),
            ListTile(
              onTap: () {},
              title: const Text("Appearrance"),
            ),
            ListTile(
              onTap: () {},
              title: const Text("Theme"),
            ),
            ListTile(
              onTap: () {},
              title: const Text("Notification"),
            ),
            ListTile(
              onTap: () {},
              title: const Text("Language"),
            ),
            ListTile(
              onTap: logOutUser,
              leading: const Icon(Icons.logout),
              title: const Text("Log Out"),
            )
          ],
        ),
      ),
    );
  }
}
