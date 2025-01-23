import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:koda/components/filter_chip_section.dart';
import 'package:koda/components/search_bar_field.dart';
import 'package:koda/helpers/format_number.dart';
import 'package:koda/helpers/get_current_locale.dart';
import 'package:koda/models/activity_model.dart';
import 'package:koda/models/storage_item_model.dart';
import 'package:koda/services/activities_service.dart';
import 'package:koda/services/storage_item_service.dart';
import 'package:koda/utils/app_colors.dart';
import 'package:koda/helpers/localization_mapper.dart';
import 'package:koda/models/store_item_model.dart';
import 'package:koda/pages/settings/profile_page.dart';
import 'package:koda/pages/store/add_store_item_form_dialog.dart';
import 'package:koda/pages/store/edit_store_form_item_dialog.dart';
import 'package:koda/services/store_item_service.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with WidgetsBindingObserver {
  String _searchText = "";
  bool _isEdit = false;
  bool _openDialog = false;
  int _indexDelete = -1;
  bool _isKeyboardOpen = false;
  bool _isLoadingSaveIntoFirebase = false;
  int _indexShowDescription = -1;
  String _selectedChipLabel = "all";

  final StoreItemService _storeItemService = StoreItemService();
  final StorageItemService _storageItemService = StorageItemService();
  final ActivitiesService _activitiesService = ActivitiesService();
  final Map<String, Map<String, dynamic>> _storeActivities = {};

  late Map<String, dynamic> _usedStorageItemsTotal = {};
  late Stream<List<StoreItem>> _storeItemStream;
  late List<String> _dropdownItem = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeStore();
    _checkKeyboardState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _storeActivities.clear();
    _onKeyboardDismiss();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _checkKeyboardState();
  }

  void _initializeStore() async {
    _storeItemStream = _storeItemService.getStoreItems();
    _dropdownItem = await _storeItemService.getStoreCategories();
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
            setState(() {
              _storeItemStream = _storeItemService.getStoreItems(
                searchField: _searchText,
                label: _selectedChipLabel,
              );
            });
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
        onSearchChanged: (value) => setState(() {
          _storeItemStream = _storeItemService.getStoreItems(
            searchField: value,
            label: _selectedChipLabel,
          );
          _searchText = value;
        }),
        onClose: () {
          _storeItemStream =
              _storeItemService.getStoreItems(label: _selectedChipLabel);
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChipSection(),
          const SizedBox(height: 30),
          _buildStoreLists(),
        ],
      ),
    );
  }

  Widget _buildFilterChipSection() {
    return FilterChipSection(
      chipLabels: [
        Text(AppLocalizations.of(context)!.all),
        DropdownSearch<String>(
          onBeforePopupOpening: (selectedItem) async {
            _dropdownItem = await _storeItemService.getStoreCategories();
            setState(() {});
            return true;
          },
        ),
      ],
      dropdownItem: _dropdownItem,
      dropdownDecoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        hintText: AppLocalizations.of(context)!.category,
        hintStyle: TextStyle(
          fontSize: 12,
          overflow: TextOverflow.ellipsis,
          color: AppColors.text,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      onSelected: (value) {
        value = getLabelValue(context, value);
        setState(() => _selectedChipLabel = value);
        _storeItemStream = _storeItemService.getStoreItems(
          searchField: _searchText,
          label: value,
        );
      },
      backgroundColor: AppColors.secondary,
      selectedColor: AppColors.selected,
      selectedIconColor: AppColors.main,
      selectedLabelColor: AppColors.secondaryText,
    );
  }

  Widget _buildStoreLists() {
    return Expanded(
      child: StreamBuilder(
          stream: _storeItemStream,
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

            return AlignedGridView.count(
              itemCount: snapshot.data!.length,
              padding: const EdgeInsets.only(bottom: 250),
              crossAxisCount: 2,
              mainAxisSpacing: 30,
              crossAxisSpacing: 30,
              itemBuilder: (context, index) {
                StoreItem item = snapshot.data![index];

                return _buildStoreItem(index: index, item: item);
              },
            );
          }),
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
          elevation: _openDialog ? 0 : null,
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

  void _showFormItemDialog({StoreItem? item}) async {
    if (_isEdit) _closeEditItem();
    setState(() => _openDialog = true);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => item == null
          ? const AddFormStoreItemDialog()
          : EditStoreFormItemDialog(item: item),
    );
    setState(() => _openDialog = false);
  }

  void _openEditItem() {
    setState(() => _isEdit = true);
  }

  void _closeEditItem() {
    _storeActivities.clear();
    setState(() => _isEdit = false);
  }

  Widget _buildStoreItem({
    required int index,
    required StoreItem item,
  }) {
    bool isDelete = _indexDelete == index;

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          GestureDetector(
            onLongPress: () => setState(() => _indexDelete = index),
            child: Stack(
              children: [
                item.image == null
                    ? Container(
                        width: constraints.maxWidth,
                        height: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xffababab)
                                  : AppColors.darkMain,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.all(15),
                        child: _buildStoreItemDescription(
                            constraints, item, index),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.image!,
                        imageBuilder: (context, imageProvider) => Container(
                          width: constraints.maxWidth,
                          height: constraints.maxWidth,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              opacity: 0.65,
                            ),
                            gradient: LinearGradient(
                              colors: [AppColors.secondary, Colors.black],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(15),
                          child: _buildStoreItemDescription(
                              constraints, item, index),
                        ),
                        placeholder: (context, url) => Container(
                          width: constraints.maxWidth,
                          height: constraints.maxWidth,
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
                  top: 10,
                  right: 10,
                  child: isDelete
                      ? ElevatedButton(
                          onPressed: () => _deleteItem(item),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.delete),
                        )
                      : IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _showFormItemDialog(item: item),
                          color: Colors.white,
                          icon: const Icon(Icons.edit),
                        ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                axisAlignment: -1,
                child: child,
              );
            },
            child: _isEdit
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: (_storeActivities[item.id]?["qty"] ?? 0) <= 0
                            ? null
                            : () {
                                setState(() {
                                  _storeActivities.update(
                                    item.id!,
                                    (value) {
                                      value["qty"]--;
                                      return value;
                                    },
                                    ifAbsent: () => {
                                      "name": item.name,
                                      "qty": -1,
                                      "usedStorageItem": item.usedStorageItems,
                                    },
                                  );
                                });
                              },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        _storeActivities[item.id]?["qty"].toString() ?? "0",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _storeActivities.update(
                              item.id!,
                              (value) {
                                value["qty"]++;
                                return value;
                              },
                              ifAbsent: () => {
                                "name": item.name,
                                "qty": 1,
                                "usedStorageItem": item.usedStorageItems,
                              },
                            );
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  )
                : const SizedBox(),
          )
        ],
      );
    });
  }

  Widget _buildStoreItemDescription(
    BoxConstraints constraints,
    StoreItem item,
    int index,
  ) {
    bool isShowDescription = _indexShowDescription == index;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isShowDescription
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              SizedBox(
                width: isShowDescription ? constraints.maxWidth - 50 : null,
                child: Text(
                  item.name == null ? "" : item.name!,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.vertical,
                    axisAlignment: -1,
                    child: child,
                  );
                },
                child: isShowDescription
                    ? SizedBox(
                        height: constraints.maxWidth - 100,
                        child: SingleChildScrollView(
                          child: Text(
                            item.description ?? "",
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            setState(
                () => _indexShowDescription = isShowDescription ? -1 : index);
          },
          child: Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(125),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isShowDescription
                  ? Icons.keyboard_arrow_up_sharp
                  : Icons.keyboard_arrow_down_sharp,
              color: Colors.white,
            ),
          ),
        )
      ],
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
    final List<Map<String, dynamic>> orderLists =
        _storeActivities.values.where((entry) => entry["qty"] != 0).toList();

    _usedStorageItemsTotal = {};
    for (final entry in orderLists) {
      final usedStorageItems =
          entry["usedStorageItem"] as List<Map<String, dynamic>>?;
      if (usedStorageItems != null) {
        for (final item in usedStorageItems) {
          final String id = item["id"];
          final String name = item["name"];
          final double qty = item["quantity"] ?? 0;
          final String unit = item["unit"];

          if (_usedStorageItemsTotal.containsKey(id)) {
            _usedStorageItemsTotal[id]!["total"] += qty * entry["qty"];
          } else {
            _usedStorageItemsTotal[id] = {
              "name": name,
              "total": qty * entry["qty"],
              "unit": unit
            };
          }
        }
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 65),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.orderLists,
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
              padding: const EdgeInsets.symmetric(horizontal: 5),
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
            ...orderLists.map(
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
                    Text(
                      item['qty'].toString(),
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 2,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.itemUsed,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 2,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 8),
            ..._usedStorageItemsTotal.values.map(
              (item) {
                return Padding(
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
                              item['total'],
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
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
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
                status: "Sold",
                details: _storeActivities.values
                    .where((entry) => entry["qty"] != 0)
                    .toList(),
              );
              _activitiesService.createActivities(activity);

              for (var entry in _usedStorageItemsTotal.entries) {
                StorageItem? item =
                    await _storageItemService.getStorageItem(entry.key);
                await _storageItemService.updateStorageItem(item!.copyWith(
                  currentWeight: item.currentWeight! - entry.value["total"],
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

  void _deleteItem(StoreItem item) async {
    if (_isEdit) _closeEditItem();
    setState(() => _indexDelete = -1);
    final snackbar = ScaffoldMessenger.of(context);
    snackbar.removeCurrentSnackBar();

    final Activity activity = Activity(
      status: "Delete",
      details: {
        "name": item.name,
        "desc": "Deleted Store Item",
      },
    );

    await _storeItemService.deleteStoreItem(item);
    String? idActivity = await _activitiesService.createActivities(activity);

    if (!mounted) return;

    snackbar.showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.oneStoreItemDeleted),
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
          _storeItemService.undoDeleteItem(item);
          _activitiesService.deleteActivity(activity.copyWith(id: idActivity));
        },
      ),
    ));
  }
}
