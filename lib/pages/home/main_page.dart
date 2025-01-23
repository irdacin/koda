import 'package:flutter/material.dart';
import 'package:koda/components/bottom_nav_bar.dart';
import 'package:koda/pages/activities/activities_page.dart';
import 'package:koda/pages/storage/storage_page.dart';
import 'package:koda/pages/store/store_page.dart';
import 'package:koda/providers/navigation_bar_provider.dart';
import 'package:koda/providers/theme_provider.dart';
import 'package:koda/utils/app_colors.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  List<String> navBarLabel = [
    "STORE",
    "STORAGE",
    "ACTIVITIES",
  ];

  final List<Widget> pages = [
    const StorePage(),
    const StoragePage(),
    const ActivitiesPage(),
  ];

  @override
  Widget build(BuildContext context) {    
    return Consumer<NavigationBarProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Stack(
            children: [
              pages[navBarLabel.indexOf(provider.navBarLabel[index])],
              if (MediaQuery.of(context).viewInsets.bottom <= 0)
                Positioned(
                  bottom: 0,
                  left: 10,
                  right: 10,
                  child: BottomNavBar(
                    currentIndex: index,
                    backgroundColor: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.light ? AppColors.background : AppColors.background,
                    items: provider.navBarLabel.map((e) {
                      return BottomNavigationBarItem(
                        icon: const Icon(Icons.store),
                        label: e,
                      );
                    },).toList(),
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
    );
  }
}
