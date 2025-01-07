import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:koda/providers/navigation_bar_provider.dart';
import 'package:koda/pages/home/splash_page.dart';
import 'package:koda/providers/language_provider.dart';
import 'package:koda/providers/theme_provider.dart';
import 'package:koda/utils/dark_theme.dart';
import 'package:koda/utils/light_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => NavigationBarProvider(),),
        ChangeNotifierProvider(create: (context) => ThemeProvider(),),
      ],
      child: Builder(
        builder: (context) {
          String? currentLanguange = context.watch<LanguageProvider>().languageCode;
          return MaterialApp(
            title: 'Koda',
            locale: currentLanguange == null ? null : Locale(context.watch<LanguageProvider>().languageCode!),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: LightTheme.theme,
            darkTheme: DarkTheme.theme,
            themeMode: context.watch<ThemeProvider>().themeMode,
            debugShowCheckedModeBanner: false,
            home: const SplashPage(),
          );
        }
      ),
    );
  }
}
