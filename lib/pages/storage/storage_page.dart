import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koda/components/filter_chip_section.dart';
import 'package:koda/components/search_bar_field.dart';
import 'package:koda/helpers/format_number.dart';
import 'package:koda/helpers/get_current_locale.dart';
import 'package:koda/models/activity_model.dart';
import 'package:koda/services/activities_service.dart';
import 'package:koda/utils/app_colors.dart';
import 'package:koda/helpers/localization_mapper.dart';
import 'package:koda/models/storage_item_model.dart';
import 'package:koda/pages/settings/profile_page.dart';
import 'package:koda/pages/storage/add_storage_form_item_dialog.dart';
import 'package:koda/pages/storage/edit_storage_form_item_dialog.dart';
import 'package:koda/services/storage_item_service.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> with WidgetsBindingObserver {
  String _searchText = "";
  int _indexDelete = -1;
  bool _isEdit = false;
  bool _openDialog = false;
  bool _isKeyboardOpen = false;
  bool _isLoadingSaveIntoFirebase = false;
  int _indexShowTheStoreUsed = -1;
  String _selectedChipLabel = "all";

  final StorageItemService _storageItemService = StorageItemService();
  final ActivitiesService _activitiesService = ActivitiesService();
  final Map<String, TextEditingController> itemControllers = {};
  final Map<String, Map<String, dynamic>> _storageActivities = {};
  late Stream<List<StorageItem>> _storageItemStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardState();
    _storageItemStream = _storageItemService.getStorageItems();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    itemControllers.clear();
    _storageActivities.clear();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _checkKeyboardState();
  }

  void _checkKeyboardState() {
    final keyboardVisible = WidgetsBinding
            .instance.platformDispatcher.views.first.viewInsets.bottom >
        0;
    setState(() => _isKeyboardOpen = keyboardVisible);
  }

  void _onKeyboardDismiss() {
    FocusScope.of(context).unfocus();
    if (_indexDelete != -1) {
      setState(() => _indexDelete = -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onKeyboardDismiss,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          color: Colors.blue,
          onRefresh: () async {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            _storageItemStream = _storageItemService.getStorageItems(
              searchField: _searchText,
              label: _selectedChipLabel,
            );
            setState(() {});
          },
          child: Stack(
            children: [
              _buildBody(),
              Positioned(
                right: 15,
                bottom: 100,
                child: !_isKeyboardOpen
                    ? _buildFloatingActions()
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: SearchBarField(
        onSearchChanged: (value) {
          _storageItemStream =
              _storageItemService.getStorageItems(searchField: value);
          setState(() => _searchText = value);
        },
        onClose: () {
          setState(
              () => _storageItemStream = _storageItemService.getStorageItems(
                    label: _selectedChipLabel,
                  ));
          _onKeyboardDismiss();
        },
        backgroundColor: AppColors.secondary,
        iconColor: AppColors.text,
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          ),
          icon: Icon(
            Icons.menu,
            size: 35,
            color: AppColors.text,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChipSection(),
          const SizedBox(height: 20),
          _buildStorageLists(),
        ],
      ),
    );
  }

  Widget _buildFilterChipSection() {
    return FilterChipSection(
      chipLabels: [
        Text(AppLocalizations.of(context)!.all),
        Text(AppLocalizations.of(context)!.full),
        const Text("> 50 %"),
        const Text("< 50 %"),
        Text(AppLocalizations.of(context)!.empty),
      ],
      onSelected: (value) {
        value = getLabelValue(context, value);
        setState(() => _selectedChipLabel = value);
        _storageItemStream = _storageItemService.getStorageItems(
          searchField: _searchText,
          label: value,
        );
      },
      backgroundColor: AppColors.secondary,
      selectedColor: AppColors.selected,
      selectedLabelColor: AppColors.secondaryText,
    );
  }

  Widget _buildStorageLists() {
    return Expanded(
      child: StreamBuilder(
        stream: _storageItemStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }

          if (snapshot.data == null) {
            return Container();
          }

          return SlidableAutoCloseBehavior(
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemCount: snapshot.data!.length,
              padding: const EdgeInsets.only(bottom: 250),
              itemBuilder: (context, index) {
                StorageItem storageItem = snapshot.data![index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.3,
                    children: [
                      SlidableAction(
                        onPressed: (context) => _deleteItem(storageItem),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        label: AppLocalizations.of(context)!.delete,
                      ),
                    ],
                  ),
                  child: _buildStorageItem(
                    index: index,
                    item: storageItem,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor: _isEdit ? AppColors.selected : AppColors.secondary,
          onPressed:
              _isEdit ? _showConfirmChoseActivitiesDialog : _openEditItem,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          heroTag: null,
          child: Icon(
            _isEdit ? FontAwesomeIcons.check : FontAwesomeIcons.penToSquare,
            size: 25,
            color: _isEdit ? Colors.white : AppColors.text,
          ),
        ),
        const SizedBox(height: 15),
        FloatingActionButton(
          backgroundColor: _isEdit ? Colors.red : AppColors.secondary,
          heroTag: null,
          onPressed: _isEdit ? _closeEditItem : _showFormItemDialog,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: _openDialog ? 0 : null,
          child: Hero(
            tag: 'fab-icon-add',
            child: Icon(
              _isEdit ? FontAwesomeIcons.xmark : FontAwesomeIcons.plus,
              size: 25,
              color: _isEdit ? Colors.white : AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  void _openEditItem() {
    setState(() => _isEdit = true);
  }

  void _closeEditItem() {
    _storageActivities.clear();
    itemControllers.clear();
    setState(() => _isEdit = false);
  }

  Widget _buildStorageItem({
    required int index,
    required StorageItem item,
  }) {
    String? image = item.image;
    String name = item.name ?? "";
    double currentWeight = item.currentWeight ?? 0;
    double maxWeight = item.maxWeight ?? 1;
    double percentage = item.percentage ?? 0;
    String unit = item.unit ?? "Kg";
    List<Map<String, dynamic>> useForStoreItem = item.useForStoreItem ?? [];
    bool isShowTheStoreUsed = _indexShowTheStoreUsed == index;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            image == null
                ? Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xffc3c3c3)
                          : AppColors.darkMain,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: image,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          opacity: 0.75,
                          fit: BoxFit.cover,
                        ),
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ),
                  ),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showFormItemDialog(item: item),
                icon: const Icon(Icons.edit),
                color: Colors.white,
              ),
            )
          ],
        ),
        const SizedBox(width: 5),
        Expanded(
          child: GestureDetector(
            onTap: useForStoreItem.isEmpty
                ? null
                : () {
                    setState(() => _indexShowTheStoreUsed =
                        isShowTheStoreUsed ? -1 : index);
                  },
            child: Container(
              decoration: isShowTheStoreUsed
                  ? BoxDecoration(
                      border: Border.all(color: AppColors.secondary),
                      borderRadius: BorderRadius.circular(5),
                    )
                  : null,
              padding: EdgeInsets.only(
                top: isShowTheStoreUsed ? 9 : 10,
                left: isShowTheStoreUsed ? 7 : 8,
                right: 10,
                bottom: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 30,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      if (_isEdit) ...[
                        Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                              color: AppColors.main,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              border: Border.all(color: AppColors.secondary)),
                          child: TextField(
                            controller: itemControllers.putIfAbsent(
                                item.id!,
                                () => TextEditingController(
                                      text: _storageActivities
                                              .containsKey(item.id!)
                                          ? _storageActivities[item.id]!["qty"]
                                          : "0",
                                    )),
                            onChanged: (value) {
                              _storageActivities.update(
                                item.id!,
                                (entry) {
                                  entry["qty"] = double.tryParse(value);
                                  return entry;
                                },
                                ifAbsent: () => {
                                  "name": item.name,
                                  "qty": double.tryParse(value),
                                  "unit": item.unit,
                                },
                              );
                            },
                            textAlign: TextAlign.end,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              filled: true,
                              fillColor: AppColors.main,
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 30,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: AppColors.main,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            border: Border.all(color: AppColors.secondary),
                          ),
                          child: Text(
                            unit,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ] else if (useForStoreItem.isNotEmpty)
                        SizedBox(
                          width: 40,
                          child: Icon(
                            isShowTheStoreUsed
                                ? Icons.keyboard_arrow_up_sharp
                                : Icons.keyboard_arrow_down_sharp,
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (!isShowTheStoreUsed) ...[
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xffe0e0e0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        Container(
                          height: 8,
                          width: percentage *
                              (MediaQuery.of(context).size.width - 150),
                          decoration: BoxDecoration(
                            color: percentage > 0.5
                                ? Colors.green
                                : percentage > 0.1
                                    ? Colors.orange
                                    : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${formatNumber(currentWeight, locale: getCurrrentLocale(context))} $unit',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${formatNumber(maxWeight, locale: getCurrrentLocale(context))} $unit',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    )
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.listItemsThatUseThisItem,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    ...useForStoreItem.map(
                      (storeItem) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.secondary),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          storeItem['name'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFormItemDialog({StorageItem? item}) async {
    if (_isEdit) _closeEditItem();
    setState(() => _openDialog = true);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => item == null
          ? const AddStorageFormItemDialog()
          : EditStorageFormItemDialog(item: item),
    );
    setState(() => _openDialog = false);
  }

  void _showDeleteAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "${AppLocalizations.of(context)!.delete}?",
          style: GoogleFonts.poppins(),
        ),
        content: Text(
          "${AppLocalizations.of(context)!.thisItemCannotDelete}.\n${AppLocalizations.of(context)!.tryToDdeleteAllStoreItemFirst}.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.ok,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmChoseActivitiesDialog() async {
    setState(() => _openDialog = true);
    bool isConfirmed = await showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            insetPadding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 60,
              bottom: 169,
            ),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: AppColors.selected,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  _buildChoseOrderLists(context),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildButtomDialogButton(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (isConfirmed) {
      _closeEditItem();
    }
    setState(() => _openDialog = true);
  }

  Widget _buildChoseOrderLists(BuildContext context) {
    final List<Map<String, dynamic>> updatedLists =
        _storageActivities.values.where((entry) => entry["qty"] != 0).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 65),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.updatedLists,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 2,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.itemName,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.qty,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 2,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 8),
            ...updatedLists.map(
              (item) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          formatNumber(
                            item['qty'],
                            locale: getCurrrentLocale(context),
                          ),
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          item['unit'],
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtomDialogButton(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 20, right: 4),
      decoration: BoxDecoration(
        color: AppColors.selected,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              if (_isLoadingSaveIntoFirebase) return;
              Navigator.pop(context, false);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.secondaryText,
                  size: 25,
                ),
                Text(
                  AppLocalizations.of(context)!.back,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              if (_isLoadingSaveIntoFirebase) return;
              setState(() => _isLoadingSaveIntoFirebase = true);

              Activity activity = Activity(
                status: "In",
                details: _storageActivities.values
                    .where((entry) => entry["qty"] != 0)
                    .toList(),
              );
              _activitiesService.createActivities(activity);

              for (var entry in _storageActivities.entries) {
                StorageItem? item =
                    await _storageItemService.getStorageItem(entry.key);
                await _storageItemService.updateStorageItem(item!.copyWith(
                  currentWeight: item.currentWeight! + entry.value["qty"],
                ));
              }

              setState(() => _isLoadingSaveIntoFirebase = false);

              if (!context.mounted) return;
              Navigator.pop(context, true);
            },
            constraints: const BoxConstraints(),
            icon: const Icon(FontAwesomeIcons.check),
            iconSize: 25,
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }

  void _deleteItem(StorageItem item) async {
    if (_isEdit) _closeEditItem();
    setState(() => _indexDelete = -1);
    final snackbar = ScaffoldMessenger.of(context);
    snackbar.removeCurrentSnackBar();

    bool isDeleted = await _storageItemService.deleteStorageItem(item);
    if (!isDeleted) {
      _showDeleteAlertDialog();
      return;
    }

    final Activity activity = Activity(
      status: "Delete",
      details: {
        "name": item.name,
        "desc": "Deleted Storage Item",
      },
    );

    String? idActivity = await _activitiesService.createActivities(activity);

    if (!mounted) return;

    snackbar.showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.oneStorageItemDeleted),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(
        bottom: 100,
        left: 15,
        right: 15,
      ),
      action: SnackBarAction(
        label: AppLocalizations.of(context)!.undo,
        textColor: AppColors.selected,
        onPressed: () {
          _storageItemService.undoDeleteItem(item);
          _activitiesService.deleteActivity(activity.copyWith(id: idActivity));
        },
      ),
    ));
  }
}
