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
  final TextEditingController storeController = TextEditingController();
  final TextEditingController storageController = TextEditingController();
  final TextEditingController activitiesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initiliazeNavigationBar();
  }

  void _initiliazeNavigationBar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      storeController.text = Provider.of<NavigationBarProvider>(context, listen: false).store;
      storageController.text =
          Provider.of<NavigationBarProvider>(context, listen: false).storage;
      activitiesController.text =
          Provider.of<NavigationBarProvider>(context, listen: false).activities;
    });
  }

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
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.topCenter,
                child: Text(
                  AppLocalizations.of(context)!.renameNavigationBar,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: SingleChildScrollView(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _buildNavBarTextField(
                        context,
                        controller: storeController,
                      ),
                      Divider(color: AppColors.secondary),
                      _buildNavBarTextField(
                        context,
                        controller: storageController,
                      ),
                      Divider(color: AppColors.secondary),
                      _buildNavBarTextField(
                        context,
                        controller: activitiesController,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarTextField(
    BuildContext context, {
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      onChanged: (value) {
        final prov = Provider.of<NavigationBarProvider>(context, listen: false);
        if (controller == storeController) {
          prov.changeStoreName(value);
        } else if (controller == storageController) {
          prov.changeStorageName(value);
        } else if (controller == activitiesController) {
          prov.changeActivitiesName(value);
        }
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
      ),
      style: const TextStyle(
        fontSize: 16,
      ),
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
    );
  }
}
