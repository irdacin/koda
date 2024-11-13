import 'package:flutter/material.dart';
import 'package:koda/helper/constant.dart';
import 'package:koda/pages/widget/home.dart';
import 'package:koda/pages/widget/side_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  final int index;

  const MainPage({
    super.key,
    this.index = 0,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool showSideBar = true;
  bool showSideBarInRight = true;

  List<Widget> pages = [
    const Home(),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (showSideBar && !showSideBarInRight) const SideBar(),
            pages[widget.index],
            if (showSideBar && showSideBarInRight) const SideBar(),
          ],
        ),
      ),
    );
  }
}
