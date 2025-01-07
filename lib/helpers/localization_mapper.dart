import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String getMappedValue(BuildContext context, String value) {
  final appLocalizations = AppLocalizations.of(context)!;

  final localizationMap = {
    appLocalizations.all: "all",
    appLocalizations.full: "full",
    appLocalizations.empty: "empty",
  };

  return localizationMap[value] ?? value;
}

String getLanguage(BuildContext context, String code) {
  final appLocalizations = AppLocalizations.of(context)!;

  final localizationMap = {
    "en": appLocalizations.english,
    "id": appLocalizations.indonesian,
  };

  return localizationMap[code] ?? code;
}
