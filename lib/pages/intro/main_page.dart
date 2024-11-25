import 'package:flutter/material.dart';
import 'package:koda/components/bottom_nav_bar.dart';
import 'package:koda/helpers/constant.dart';
import 'package:koda/pages/activities/activities_page.dart';
import 'package:koda/pages/storage/storage_page.dart';
import 'package:koda/pages/store/store_page.dart';
import 'package:koda/pages/home/widget/side_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController searchController = TextEditingController();
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
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {});
          },
          controller: searchController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController.clear();
                    },
                    icon: const Icon(Icons.cancel_outlined),
                  )
                : Icon(
                    Icons.manage_search_rounded,
                    size: 30,
                  ),
            filled: true,
            fillColor: Color(0xffd9d9d9),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.account_circle_rounded,
              size: 30,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavBar(
        currentIndex: index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "STORE",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: "STORAGE",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity_outlined),
            label: "ACTIVITIES",
          ),
        ],
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
      ),
    );
  }
}
