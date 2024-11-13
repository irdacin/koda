import 'package:flutter/material.dart';
import 'package:koda/helper/constant.dart';
import 'package:koda/pages/main_page.dart';
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

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showSideBar = prefs.getBool(KEY_SHOW_SIDE_BAR) ?? true;
      showSideBarInRight = prefs.getBool(KEY_SHOW_SIDE_BAR_IN_RIGHT) ?? true;
    });
  }

  void save(String key) async {
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
                        builder: (context) => MainPage(),
                      ));
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 20),
                  Icon(Icons.settings),
                  SizedBox(width: 20),
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              onTap: () {},
              title: Text("Profile"),
            ),
            ListTile(
              onTap: () {},
              title: Text("Appearrance"),
            ),
            ListTile(
              onTap: () {},
              title: Text("Theme"),
            ),
            ListTile(
              onTap: () {},
              title: Text("Notification"),
            ),
            ListTile(
              onTap: () {},
              title: Text("Language"),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
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
                        padding: EdgeInsets.all(5),
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
                      SizedBox(width: 5),
                      Text(
                        "/",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        decoration: !showSideBar
                            ? BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              )
                            : null,
                        padding: EdgeInsets.all(5),
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
                padding: EdgeInsets.symmetric(horizontal: 16),
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
                      padding: EdgeInsets.all(5),
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
                              color: !showSideBarInRight ? Colors.white : null),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "/",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      decoration: showSideBarInRight
                          ? BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      padding: EdgeInsets.all(5),
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
                              color: showSideBarInRight ? Colors.white : null),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
