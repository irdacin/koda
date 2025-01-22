import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:koda/helpers/localization_mapper.dart';
import 'package:koda/pages/auth/login_page.dart';
import 'package:koda/pages/settings/navigation_bar_page.dart';
import 'package:koda/pages/settings/account_page.dart';
import 'package:koda/providers/language_provider.dart';
import 'package:koda/providers/theme_provider.dart';
import 'package:koda/services/auth_service.dart';
import 'package:koda/utils/app_colors.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> codeLanguages = [
    "en",
    "id",
  ];

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        leadingWidth: 100,
        title: Text(AppLocalizations.of(context)!.profile),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AccountPage()),
              );
            },
            icon: const Icon(Icons.person),
            iconSize: 30,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.customize,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const NavigationBarPage(),
                    )),
                    child: Text(
                      AppLocalizations.of(context)!.navigationBar,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    AppLocalizations.of(context)!.theme,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SwitchListTile(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: context.read<ThemeProvider>().toggleTheme,
                    title: Text(
                      AppLocalizations.of(context)!.lightDarkMode,
                      style: const TextStyle(fontSize: 14),
                    ),
                    activeColor: AppColors.selected,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    AppLocalizations.of(context)!.languages,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: DropdownSearch<String>(
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15),
                          filled: true,
                          fillColor: AppColors.secondary,
                        ),
                        baseStyle: const TextStyle(
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selectedItem: getLanguage(
                        context,
                        context.read<LanguageProvider>().languageCode!,
                      ),
                      suffixProps: const DropdownSuffixProps(
                        dropdownButtonProps: DropdownButtonProps(
                          padding: EdgeInsets.zero,
                          iconClosed: Icon(Icons.keyboard_arrow_down),
                          iconOpened: Icon(Icons.keyboard_arrow_up),
                        ),
                      ),
                      items: (filter, loadProps) => codeLanguages,
                      itemAsString: (code) => getLanguage(context, code),
                      onChanged: (value) => context
                          .read<LanguageProvider>()
                          .changeLanguageCode(value),
                      popupProps: const PopupProps.menu(
                        fit: FlexFit.loose,
                        menuProps: MenuProps(
                          margin: EdgeInsets.only(top: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.all(30),
                child: GestureDetector(
                  onTap: signOutUser,
                  child: Text(
                    AppLocalizations.of(context)!.signOut,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> signOutUser() async {
    await _authService.logout();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
