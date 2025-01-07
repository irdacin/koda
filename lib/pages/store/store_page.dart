import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:koda/components/filter_chip_section.dart';
import 'package:koda/components/search_bar_field.dart';
import 'package:koda/utils/app_colors.dart';
import 'package:koda/helpers/localization_mapper.dart';
import 'package:koda/models/store_item_model.dart';
import 'package:koda/pages/settings/settings_page.dart';
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
  int _indexShowDescription = -1;
  String _selectedChipLabel = "all";

  final StoreItemService _storeItemService = StoreItemService();
  late Stream<List<StoreItem>> _storeItemStream;
  List<String> _dropdownItem = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardState();
    _initializeStore();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
            _storeItemStream = _storeItemService.getStoreItems(
              searchField: _searchText,
              label: _selectedChipLabel,
            );
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          ),
          icon: const Icon(
            Icons.menu,
            size: 35,
            color: Colors.black,
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
        hintText: AppLocalizations.of(context)!.categories,
        hintStyle: TextStyle(
          fontSize: 12,
          overflow: TextOverflow.ellipsis,
          color: AppColors.text,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      onSelected: (value) {
        value = getMappedValue(context, value);
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
          onPressed: () {
            setState(() => _isEdit ^= true);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          heroTag: null,
          child: Icon(
            _isEdit ? FontAwesomeIcons.check : FontAwesomeIcons.penToSquare,
            size: 25,
            color: _isEdit ? Colors.white : Colors.black,
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
              color: _isEdit ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _showFormItemDialog({StoreItem? item}) async {
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

  void _closeEditItem() {
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
                          color: const Color(0xffababab),
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
                            backgroundColor: AppColors.main,
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
                          color: AppColors.main,
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
                        onPressed: () {},
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        "0",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
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
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.description,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 12,
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
              color: AppColors.main.withAlpha(125),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isShowDescription
                  ? Icons.keyboard_arrow_up_sharp
                  : Icons.keyboard_arrow_down_sharp,
              color: AppColors.main,
            ),
          ),
        )
      ],
    );
  }

  void _deleteItem(StoreItem item) async {
    setState(() => _indexDelete = -1);
    final snackbar = ScaffoldMessenger.of(context);
    snackbar.hideCurrentSnackBar();

    await _storeItemService.deleteStoreItem(item);

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
        onPressed: () => _storeItemService.undoDeleteItem(item),
      ),
    ));
  }
}
