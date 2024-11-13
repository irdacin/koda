import 'package:flutter/material.dart';
import 'package:koda/database/database_item.dart';
import 'package:koda/pages/form_item_page.dart';
import 'package:koda/pages/settings_page.dart';
import 'package:provider/provider.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
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
                  vertical: 24,
                  horizontal: 5,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ));
                },
                icon: const Icon(Icons.settings),
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
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: Provider.of<DatabaseItem>(context).read(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!.reversed
                          .map(
                            (e) => Container(
                              width: 30,
                              height: 30,
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xffA9a9a9),
                                borderRadius: BorderRadius.circular(10),
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
}
