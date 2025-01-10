import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koda/utils/app_colors.dart';
import 'package:koda/models/storage_item_model.dart';
import 'package:koda/models/store_item_model.dart';
import 'package:koda/services/image_service.dart';
import 'package:koda/services/storage_item_service.dart';
import 'package:koda/services/store_item_service.dart';
import 'package:permission_handler/permission_handler.dart';

class AddFormStoreItemDialog extends StatefulWidget {
  const AddFormStoreItemDialog({super.key});

  @override
  State<AddFormStoreItemDialog> createState() => _AddFormStoreItemDialogState();
}

class _AddFormStoreItemDialogState extends State<AddFormStoreItemDialog>
    with WidgetsBindingObserver {
  bool _isKeyboardOpen = false;
  bool _isExpand = false;
  bool _isLoadingSaveIntoFirebase = false;
  List<StorageItem> storageItems = [];
  StorageItem? _storageItem;
  String _selectedStorageUnit = "kg";

  Uint8List? image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController quantityController =
      TextEditingController(text: "0");
  final TextEditingController descriptionController = TextEditingController();

  final StoreItemService _storeItemService = StoreItemService();
  final List<Map<String, dynamic>> _selectedStorageItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardState();
    _initilizeForm();
  }

  void _initilizeForm() async {
    storageItems = await StorageItemService().getStorageItemsList();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nameController.dispose();
    categoryController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
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
    setState(() {
      _isKeyboardOpen = keyboardVisible;
    });
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
      onTap: () => {
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
                          onPressed: () =>
                              _loadImage(context, source: ImageSource.camera),
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
                          onPressed: () =>
                              _loadImage(context, source: ImageSource.gallery),
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
      child: image == null
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
                  fit: BoxFit.cover,
                ),
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
                        items: (filter, infiniteScrollProps) => storageItems,
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
                                        color: isDisabled ? AppColors.disableText : AppColors.text,
                                      ),
                                    ),
                                  );
                          },
                          fit: FlexFit.loose,
                          showSearchBox: true,
                          disabledItemFn: (item) {
                            return _selectedStorageItems
                                .any((selected) => selected['id'] == item.id);
                          },
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

                      _selectedStorageItems.add({
                        "id": _storageItem?.id,
                        "image": _storageItem?.image,
                        "name": _storageItem?.name,
                        "quantity": double.tryParse(quantityController.text),
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
                setState(() => _isExpand ^= true);
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
    return _selectedStorageItems.map(
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
                  ? Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.image),
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
                  Text("${quantity?.toInt()}"),
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
              )
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
          IconButton(
            onPressed: () {},
            icon: const Icon(FontAwesomeIcons.paste),
            iconSize: 30,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (_isLoadingSaveIntoFirebase) return;
                setState(() => _isLoadingSaveIntoFirebase = true);

                final navigator = Navigator.of(context);

                StoreItem newItem = StoreItem(
                  image: image != null
                      ? await ImageService.uploadImage(image!)
                      : null,
                  name: nameController.text,
                  category: categoryController.text,
                  usedStorageItems: _selectedStorageItems,
                  description: descriptionController.text,
                );
                await _storeItemService.createStoreItem(newItem);

                setState(() => _isLoadingSaveIntoFirebase = false);
                navigator.pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.main,
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
                      child: CircularProgressIndicator(
                        color: AppColors.main,
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
