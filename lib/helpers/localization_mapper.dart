import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String getLabelValue(BuildContext context, String value) {
  final appLocalizations = AppLocalizations.of(context)!;

  final localizationMap = {
    appLocalizations.all: "all",
    appLocalizations.full: "full",
    appLocalizations.empty: "empty",
    appLocalizations.today: "today",
    appLocalizations.addedStoreItem: "Added Store Item",
    appLocalizations.addedStorageItem: "Added Storage Item",
    appLocalizations.editedStoreItem: "Edited Store Item",
    appLocalizations.editedStorageItem: "Edited Storage Item",
    appLocalizations.deletedStoreItem: "Deleted Store Item",
    appLocalizations.deletedStorageItem: "Deleted Storage Item",
    appLocalizations.add: "Add",
    appLocalizations.edit: "Edit",
    appLocalizations.inn: "In",
    appLocalizations.delete: "Delete",
    appLocalizations.sold: "Sold",
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

String getActivityValue(BuildContext context, String code) {
  final appLocalizations = AppLocalizations.of(context)!;

  final localizationMap = {
    "Added Store Item": appLocalizations.addedStoreItem,
    "Added Storage Item": appLocalizations.addedStorageItem,
    "Edited Store Item": appLocalizations.editedStoreItem,
    "Edited Storage Item": appLocalizations.editedStorageItem,
    "Deleted Store Item": appLocalizations.deletedStoreItem,
    "Deleted Storage Item": appLocalizations.deletedStorageItem,
    "Add": appLocalizations.add,
    "Edit": appLocalizations.edit,
    "In": appLocalizations.inn,
    "Delete": appLocalizations.delete,
    "Sold": appLocalizations.sold,
  };

  return localizationMap[code] ?? code;
}
