import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koda/helpers/format_number.dart';
import 'package:koda/helpers/get_current_locale.dart';
import 'package:koda/models/activity_model.dart';
import 'package:koda/services/activities_service.dart';
import 'package:koda/utils/app_colors.dart';
import 'package:koda/models/storage_item_model.dart';
import 'package:koda/models/store_item_model.dart';
import 'package:koda/services/image_service.dart';
import 'package:koda/services/storage_item_service.dart';
import 'package:koda/services/store_item_service.dart';
import 'package:permission_handler/permission_handler.dart';

class EditStoreFormItemDialog extends StatefulWidget {
  final StoreItem item;
  const EditStoreFormItemDialog({super.key, required this.item});

  @override
  State<EditStoreFormItemDialog> createState() =>
      _EditStoreFormItemDialogState();
}

class _EditStoreFormItemDialogState extends State<EditStoreFormItemDialog>
    with WidgetsBindingObserver {
  bool _isKeyboardOpen = false;
  bool _isExpand = false;
  List<StorageItem> _storageItems = [];

  Uint8List? image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController quantityController =
      TextEditingController(text: "0");
  final TextEditingController descriptionController = TextEditingController();

  final StoreItemService _storeItemService = StoreItemService();
  final ActivitiesService _activitiesService = ActivitiesService();
  final List<Map<String, dynamic>> _addSelectedStorageItems = [];
  List<Map<String, dynamic>> _selectedStorageItems = [];
  bool _isLoadingLoadImage = false;
  bool _isLoadingSaveIntoFirebase = false;

  StorageItem? _storageItem;
  String _selectedStorageUnit = "kg";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardState();
    _initializeForm();
  }

  void _initializeForm() async {
    nameController.text = widget.item.name ?? "";
    categoryController.text = widget.item.category ?? "";
    descriptionController.text = widget.item.description ?? "";
    _storageItems = await StorageItemService().getStorageItemsList();
    _selectedStorageItems = widget.item.usedStorageItems ?? [];
    if (_selectedStorageItems.isNotEmpty) _isExpand = true;

    setState(() => _isLoadingLoadImage = true);
    image = widget.item.image != null
        ? await ImageService.fetchImageBytes(widget.item.image!)
        : null;
    setState(() => _isLoadingLoadImage = false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nameController.dispose();
    categoryController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    _addSelectedStorageItems.clear();
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: _isKeyboardOpen ? 20 : 100,
      ),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: AppColors.secondary,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            _buildFormStoreItem(context),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildButtomButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormStoreItem(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 15, 11, 65),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _buildImageForm(context),
          const SizedBox(height: 15),
          _buildTextFieldForm(
            hintText: AppLocalizations.of(context)!.productName,
            controller: nameController,
          ),
          const SizedBox(height: 15),
          _buildTextFieldForm(
            hintText: AppLocalizations.of(context)!.productCategory,
            controller: categoryController,
          ),
          const SizedBox(height: 15),
          _buildFormSelectedStorageItem(context),
          const SizedBox(height: 15),
          _buildTextFieldForm(
            hintText: AppLocalizations.of(context)!.description,
            maxLines: 3,
            controller: descriptionController,
          ),
        ]),
      ),
    );
  }

  Widget _buildImageForm(BuildContext context) {
    return GestureDetector(
      onTap: () => _isLoadingLoadImage
          ? null
          : {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: const Border.fromBorderSide(
                                  BorderSide(color: Colors.black),
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                onPressed: () => _loadImage(
                                  context,
                                  source: ImageSource.camera,
                                ),
                                color: Colors.black,
                                icon: const Icon(Icons.camera_alt),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(AppLocalizations.of(context)!.takePicture),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: const Border.fromBorderSide(
                                  BorderSide(color: Colors.black),
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                onPressed: () => _loadImage(context,
                                    source: ImageSource.gallery),
                                color: Colors.black,
                                icon: const Icon(Icons.image),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(AppLocalizations.of(context)!.fromGallery)
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            },
      child: _isLoadingLoadImage
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.main,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : image == null
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.main,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image,
                    size: 60,
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(image!),
                    ),
                    color: AppColors.main,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
    );
  }

  Future<void> _loadImage(
    BuildContext context, {
    required ImageSource source,
  }) async {
    final navigator = Navigator.of(context);

    PermissionStatus permissionStatus;
    if (source == ImageSource.camera) {
      permissionStatus = await Permission.camera.request();
    } else if (source == ImageSource.gallery) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      permissionStatus = androidDeviceInfo.version.sdkInt <= 32
          ? await Permission.storage.request()
          : await Permission.photos.request();
    } else {
      return;
    }

    if (!permissionStatus.isGranted) {
      if (permissionStatus.isPermanentlyDenied) {
        await openAppSettings();
      }
      return;
    }

    XFile? pickedFile = await ImagePicker().pickImage(
      source: source,
    );
    if (pickedFile == null) return;
    Uint8List newImage = await pickedFile.readAsBytes();
    if (!mounted) return;
    setState(() => image = newImage);
    if (!mounted) return;
    navigator.pop();
  }

  Widget _buildTextFieldForm({
    String? hintText,
    int? maxLines,
    TextEditingController? controller,
  }) {
    return TextField(
      style: const TextStyle(fontSize: 12),
      maxLines: maxLines ?? 1,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: 12,
          color: AppColors.text,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppColors.main,
      ),
    );
  }

  Widget _buildFormSelectedStorageItem(
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.main,
        borderRadius: BorderRadius.circular(5),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: AppColors.main,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    blurStyle: BlurStyle.solid,
                    color: AppColors.secondary,
                    offset: const Offset(0.0, 1.0),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 30,
                      ),
                      child: DropdownSearch<StorageItem>(
                        compareFn: (item1, item2) {
                          return item1.name == item2.name;
                        },
                        decoratorProps: DropDownDecoratorProps(
                          baseStyle: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 10,
                          ),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                                  BorderSide(color: AppColors.secondary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                                  BorderSide(color: AppColors.secondary),
                            ),
                            hintText:
                                AppLocalizations.of(context)!.chooseStorageItem,
                            hintStyle: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 10,
                              color: AppColors.text,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 5),
                            filled: true,
                            fillColor: AppColors.main,
                          ),
                        ),
                        items: (filter, infiniteScrollProps) => _storageItems,
                        suffixProps: const DropdownSuffixProps(
                          dropdownButtonProps: DropdownButtonProps(
                            padding: EdgeInsets.zero,
                            iconClosed: Icon(Icons.keyboard_arrow_down),
                            iconOpened: Icon(Icons.keyboard_arrow_up),
                          ),
                        ),
                        itemAsString: (item) {
                          return item.name ?? "";
                        },
                        selectedItem: _storageItem,
                        popupProps: PopupProps.menu(
                          itemBuilder: (context, item, isDisabled, isSelected) {
                            return item.name == null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      item.name!,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: isDisabled
                                              ? AppColors.disableText
                                              : AppColors.text),
                                    ),
                                  );
                          },
                          disabledItemFn: (item) {
                            return (_selectedStorageItems +
                                    _addSelectedStorageItems)
                                .any((selected) => selected['id'] == item.id);
                          },
                          fit: FlexFit.loose,
                          showSearchBox: true,
                          searchDelay: Duration.zero,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                              constraints: const BoxConstraints(maxHeight: 30),
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                          menuProps: const MenuProps(
                            margin: EdgeInsets.only(top: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          _storageItem = value!;
                          setState(() => _selectedStorageUnit = value.unit!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: quantityController,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        constraints: const BoxConstraints(maxHeight: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 30,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppColors.main,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppColors.secondary),
                    ),
                    child: Text(
                      _selectedStorageUnit,
                      style: const TextStyle(
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () {
                      if (_storageItem == null) return;

                      _addSelectedStorageItems.add({
                        "id": _storageItem?.id,
                        "image": _storageItem?.image,
                        "name": _storageItem?.name,
                        "quantity": double.parse(quantityController.text),
                        "unit": _storageItem?.unit,
                      });
                      _resetSelectStorageItem();
                    },
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
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
            child: _isExpand
                ? Column(
                    children: _buildSelectedStorageItem(),
                  )
                : const SizedBox(),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpand ^= true;
                });
              },
              child: Icon(
                _isExpand
                    ? Icons.keyboard_arrow_up_sharp
                    : Icons.keyboard_arrow_down_sharp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetSelectStorageItem() {
    setState(() {
      _isExpand = true;
      _selectedStorageUnit = "kg";
      quantityController.text = "0";
      _storageItem = null;
    });
  }

  List<Widget> _buildSelectedStorageItem() {
    final currentSelectedStorageItems =
        _selectedStorageItems + _addSelectedStorageItems;
    return currentSelectedStorageItems.map(
      (e) {
        String? image = e["image"];
        String? name = e["name"];
        String? unit = e["unit"];
        double? quantity = e["quantity"];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.secondary),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              image == null
                  ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: Icon(
                        Icons.image,
                        size: 25,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: image,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.image),
                      ),
                    ),
              Text(name ?? ""),
              Row(
                children: [
                  Text(
                    formatNumber(
                      quantity ?? 0,
                      locale: getCurrrentLocale(context),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(unit ?? ""),
                ],
              ),
              IconButton(
                padding: const EdgeInsets.all(3),
                constraints: const BoxConstraints(),
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  _selectedStorageItems.remove(e);
                  setState(() => _isExpand = _selectedStorageItems.isNotEmpty);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        );
      },
    ).toList();
  }

  Widget _buildButtomButton(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 10, right: 5),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (_isLoadingSaveIntoFirebase) return;
                setState(() => _isLoadingSaveIntoFirebase = true);
                final usedStorageItems = _selectedStorageItems + _addSelectedStorageItems;

                StoreItem newItem = widget.item.copyWith(
                  image: image != null
                      ? await ImageService.uploadImage(image!)
                      : null,
                  name: nameController.text,
                  category: categoryController.text,
                  usedStorageItems: usedStorageItems,
                  description: descriptionController.text,
                );
                await _storeItemService.updateStoreItem(newItem);
                await _storeItemService.updateToStorageItem(newItem);

                Activity activity = Activity(
                  status: "Edit",
                  details: {
                    "name": nameController.text,
                    "desc": "Edited Store Item",
                  },
                );
                await _activitiesService.createActivities(activity);

                setState(() => _isLoadingSaveIntoFirebase = false);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.selected,
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoadingSaveIntoFirebase
                  ? Container(
                      width: 22.5,
                      height: 22.5,
                      padding: const EdgeInsets.all(2),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(AppLocalizations.of(context)!.save),
            ),
          ),
          const SizedBox(width: 5),
          Hero(
            tag: 'fab-icon-add',
            child: IconButton(
              onPressed: () {
                if (_isLoadingSaveIntoFirebase) return;
                Navigator.of(context).pop();
              },
              icon: const Icon(FontAwesomeIcons.xmark),
              iconSize: 30,
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
