import 'package:flutter/material.dart';
import 'package:koda/components/bottom_nav_bar.dart';
import 'package:koda/pages/activities/activities_page.dart';
import 'package:koda/pages/storage/storage_page.dart';
import 'package:koda/pages/store/store_page.dart';
import 'package:koda/providers/navigation_bar_provider.dart';
import 'package:provider/provider.dart';

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
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.store),
                    label: Provider.of<NavigationBarProvider>(context).store,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.storage),
                    label: Provider.of<NavigationBarProvider>(context).storage,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.local_activity_outlined),
                    label: Provider.of<NavigationBarProvider>(context).activities,
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
