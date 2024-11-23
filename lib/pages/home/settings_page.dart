import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:koda/pages/auth/login_page.dart';
import 'package:koda/pages/intro/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool showSideBar = true;
  bool showSideBarInRight = true;

  @override
  void initState() {
    super.initState();
    loadData();
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

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showSideBar = prefs.getBool(KEY_SHOW_SIDE_BAR) ?? true;
      showSideBarInRight = prefs.getBool(KEY_SHOW_SIDE_BAR_IN_RIGHT) ?? true;
    });
  }

  Future<void> save(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      key,
      key == KEY_SHOW_SIDE_BAR ? showSideBar : showSideBarInRight,
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
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const MainPage(),
                      ));
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Sidebar",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: showSideBar
                            ? BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              )
                            : null,
                        padding: const EdgeInsets.all(5),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              showSideBar = true;
                            });
                            save(KEY_SHOW_SIDE_BAR);
                          },
                          child: Text(
                            "On",
                            style: TextStyle(
                              fontSize: 18,
                              color: showSideBar ? Colors.white : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "/",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        decoration: !showSideBar
                            ? BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              )
                            : null,
                        padding: const EdgeInsets.all(5),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              showSideBar = false;
                            });
                            save(KEY_SHOW_SIDE_BAR);
                          },
                          child: Text(
                            "Off",
                            style: TextStyle(
                              fontSize: 18,
                              color: !showSideBar ? Colors.white : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showSideBar)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: !showSideBarInRight
                          ? BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      padding: const EdgeInsets.all(5),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showSideBarInRight = false;
                          });
                          save(KEY_SHOW_SIDE_BAR_IN_RIGHT);
                        },
                        child: Text(
                          "Left",
                          style: TextStyle(
                            fontSize: 18,
                            color: !showSideBarInRight ? Colors.white : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "/",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      decoration: showSideBarInRight
                          ? BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      padding: const EdgeInsets.all(5),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showSideBarInRight = true;
                          });
                          save(KEY_SHOW_SIDE_BAR_IN_RIGHT);
                        },
                        child: Text(
                          "Right",
                          style: TextStyle(
                            fontSize: 18,
                            color: showSideBarInRight ? Colors.white : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
