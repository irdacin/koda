import 'package:flutter/material.dart';
import 'package:koda/components/bottom_nav_bar.dart';
import 'package:koda/helpers/constant.dart';
import 'package:koda/pages/home/activities_page.dart';
import 'package:koda/pages/home/storage_page.dart';
import 'package:koda/pages/home/store_page.dart';
import 'package:koda/pages/home/widget/side_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool showSideBar = true;
  bool showSideBarInRight = true;
  int index = 0;

  List<Widget> pages = [
    const StorePage(),
    const StoragePage(),
    const ActivitiesPage(),
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
      body: pages[index],
      bottomNavigationBar: BottomNavBar(
        currentIndex: index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "STORE"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: "STORAGE"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity_outlined),
            label: "ACTIVITIES"
          ),
        ],
        onTap: (value) {
          setState(() {
            index = value;
          });
        }
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: const Color(0xffd9d9d9),
            onPressed: () {},
            heroTag: null,
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            backgroundColor: const Color(0xffd9d9d9),
            heroTag: null,
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
