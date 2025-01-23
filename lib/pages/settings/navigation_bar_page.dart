import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:koda/providers/navigation_bar_provider.dart';
import 'package:koda/utils/app_colors.dart';
import 'package:provider/provider.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationBarProvider>(context);
    final navBarLabel = navProvider.navBarLabel;

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
                  AppLocalizations.of(context)!.holdAndDragToArrangeNavigation,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Flexible(
              flex: 4,
              child: Container(
                width: 200,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary),
                ),
                padding: const EdgeInsets.all(10),
                child: ReorderableListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      key: ValueKey(navBarLabel[index]),
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 100,
                            width: double.infinity,
                            decoration: const BoxDecoration(),
                            child: Text(
                              navBarLabel[index],
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (index < navBarLabel.length - 1)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Divider(
                                color: AppColors.secondary,
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = navBarLabel.removeAt(oldIndex);
                      navBarLabel.insert(newIndex, item);
                    });

                    Provider.of<NavigationBarProvider>(context, listen: false).saveNavigationOrder(navBarLabel);
                  },
                  itemCount: navBarLabel.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
