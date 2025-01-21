import 'package:flutter/material.dart';
import 'package:koda/providers/language_provider.dart';
import 'package:provider/provider.dart';

String? getCurrrentLocale(BuildContext context) {
  String? languageCode = context.read<LanguageProvider>().languageCode;
  return languageCode == null
      ? null
      : languageCode == "id"
          ? "id_ID"
          : languageCode == "en"
              ? "en_US"
              : null;
}
