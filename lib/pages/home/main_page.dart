import 'package:flutter/material.dart';
import 'package:koda/components/bottom_nav_bar.dart';
import 'package:koda/pages/activities/activities_page.dart';
import 'package:koda/pages/storage/storage_page.dart';
import 'package:koda/pages/store/store_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  final List<Widget> pages = [
    const StorePage(),
    const StoragePage(),
    const ActivitiesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pages[index],
          if (MediaQuery.of(context).viewInsets.bottom <= 0)
            Positioned(
              bottom: 0,
              left: 10,
              right: 10,
              child: BottomNavBar(
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
            ),
        ],
      ),
    );
  }
}
