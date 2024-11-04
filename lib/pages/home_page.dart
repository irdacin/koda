import 'package:flutter/material.dart';
import 'package:koda/pages/widget/home.dart';
import 'package:koda/pages/widget/side_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Row(
          children: [ 
            Home(),
            SideBar(),
          ],
        ),
      ),
    );
  }
}
