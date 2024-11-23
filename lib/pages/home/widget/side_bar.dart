import 'package:flutter/material.dart';
import 'package:koda/pages/home/settings_page.dart';
import 'package:sidebarx/sidebarx.dart';

Widget SideBar(BuildContext context) {
  final SidebarXController controller = SidebarXController(selectedIndex: 0);

  return SidebarX(
    controller: controller,
    theme: SidebarXTheme(
      decoration: BoxDecoration(
        color: const Color(0xffBE3E3E),
        // borderRadius: BorderRadius.circular(20),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      textStyle: const TextStyle(color: Colors.white),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xffBE3E3E),
      ),
      selectedIconTheme: const IconThemeData(
        color: Colors.white,
      ),
      selectedTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    extendedTheme: const SidebarXTheme(
      width: 200,
      decoration: BoxDecoration(
        color: Color(0xffBE3E3E),
      ),
    ),
    // extendIcon: Icons.,
    collapseIcon: Icons.abc,
    headerBuilder: (context, extended) {
      return const Padding(
        padding: EdgeInsets.all(0),
        child: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: Icon(Icons.account_circle, size: 40, color: Colors.red),
        ),
      );
    },
    items: [
      SidebarXItem(
        icon: Icons.person,
        label: 'Profile',
        onTap: () {
          debugPrint('Profile Tapped');
        },
      ),
      SidebarXItem(
        icon: Icons.settings,
        label: 'Settings',
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SettingsPage(),
          ));
        },
      ),
      const SidebarXItem(
        icon: Icons.logout,
        label: 'Sign out',
      ),
    ],
  );
}
