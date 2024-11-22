import 'package:flutter/material.dart';
import 'package:koda/database/database_item.dart';
import 'package:koda/pages/home/settings_page.dart';
import 'package:koda/pages/home/widget/form_item_page.dart';

Widget SideBar(BuildContext context) {
  final DatabaseItem db = DatabaseItem();

  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.purple],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    height: MediaQuery.of(context).size.height,
    child: Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              padding: const EdgeInsets.symmetric(
                // vertical: 24,
                horizontal: 5,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ));
              },
              icon: const Icon(Icons.settings),
              color: Colors.white,
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              onPressed: () {},
              icon: const Icon(Icons.history),
              color: Colors.white,
            ),
            Container(
              width: 20,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Flexible(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: db.read(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: snapshot.data!.reversed
                          .map(
                            (e) => GestureDetector(
                              // onTap: () {
                              //   Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => ItemDetailPage(item: e),
                              //   ));
                              // },
                              child: Container(
                                width: 30,
                                height: 30,
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xffA9a9a9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  e.name == null
                                      ? "F"
                                      : e.name!.isNotEmpty
                                          ? e.name![0].toUpperCase()
                                          : "F",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return Container();
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Column(
          children: [
            Container(
              width: 20,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(
                vertical: 50,
                horizontal: 5,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FormItemPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add,
                size: 30,
              ),
              color: Colors.yellow,
            ),
          ],
        ),
      ],
    ),
  );
}
