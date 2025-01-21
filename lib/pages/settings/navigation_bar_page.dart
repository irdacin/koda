import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:koda/utils/app_colors.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  List<String> navBarLabel = [
    "STORE",
    "STORAGE",
    "ACTIVITIES",
  ];

  @override
  void initState() {
    super.initState();
    _initiliazeNavigationBar();
  }

  void _initiliazeNavigationBar() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        leadingWidth: 100,
        title: Text(AppLocalizations.of(context)!.navigationBar),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.topCenter,
                child: Text(
                  "Hold and Drag to arrange navigation",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary),
                ),
                padding: EdgeInsets.all(10),
                child: ReorderableListView(
                    clipBehavior: Clip.hardEdge,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }

                        final item = navBarLabel.removeAt(oldIndex);
                        navBarLabel.insert(newIndex, item);
                      });
                    },
                    children: [
                      for (int index = 0; index < navBarLabel.length; index++)
                        Container(
                          key: ValueKey(navBarLabel[index]),
                          alignment: Alignment.center,
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          child: Container(

                            child: Text(
                              navBarLabel[index],
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
