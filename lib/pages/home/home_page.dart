import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:koda/pages/home/widget/home.dart';
import 'package:koda/pages/home/widget/side_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final int index;

  const HomePage({
    super.key,
    this.index = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showSideBar = true;
  bool showSideBarInRight = true;

  List<Widget> pages = [
    Home(),
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
            if (showSideBar && !showSideBarInRight) SideBar(context),
            pages[widget.index],
            if (showSideBar && showSideBarInRight) SideBar(context),
          ],
        ),
      ),
    );
  }
}
