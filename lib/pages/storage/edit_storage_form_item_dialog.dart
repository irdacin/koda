import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koda/helpers/app_colors.dart';
import 'package:koda/models/storage_item_model.dart';
import 'package:koda/services/image_service.dart';
import 'package:koda/services/storage_item_service.dart';
import 'package:permission_handler/permission_handler.dart';

class EditStorageFormItemDialog extends StatefulWidget {
  final StorageItem item;
  const EditStorageFormItemDialog({
    super.key,
    required this.item,
  });

  @override
  State<EditStorageFormItemDialog> createState() =>
      _EditStorageFormItemDialogState();
}

class _EditStorageFormItemDialogState extends State<EditStorageFormItemDialog>
    with WidgetsBindingObserver {
  Uint8List? _image;
  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedUnit = "kg";
  List<String> units = [
    "kg",
    "g",
    "L",
    "mL",
    "pcs",
  ];

  bool _isKeyboardOpen = false;
  bool _isLoadingLoadImage = false;
  bool _isLoadingSaveIntoFirebase = false;
  final StorageItemService _storageItemService = StorageItemService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardState();
    _initiliazeForm();
  }

  void _initiliazeForm() async {
    nameController.text = widget.item.name ?? "";
    weightController.text = widget.item.maxWeight.toString();
    descriptionController.text = widget.item.description ?? "";
    selectedUnit = widget.item.unit ?? "kg";
    setState(() => _isLoadingLoadImage = true);
    _image = widget.item.image != null
        ? await ImageService.fetchImageBytes(widget.item.image!)
        : null;
    setState(() => _isLoadingLoadImage = false);
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
            _buildFormStorageItem(context),
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

  Widget _buildFormStorageItem(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 15, 11, 65),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageForm(context),
            const SizedBox(height: 15),
            _buildTextFieldForm(
              hintText: "Product Name",
              controller: nameController,
            ),
            const SizedBox(height: 15),
            _buildFormInputWeight(
              controller: weightController,
            ),
            const SizedBox(height: 15),
            _buildTextFieldForm(
              hintText: "Description",
              maxLines: 3,
              controller: descriptionController,
            ),
          ],
        ),
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
                                onPressed: () => _loadImage(context,
                                    source: ImageSource.camera),
                                color: Colors.black,
                                icon: const Icon(
                                  Icons.camera_alt,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text("Take Picture")
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: const Border.fromBorderSide(
                                  BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                onPressed: () => _loadImage(context,
                                    source: ImageSource.gallery),
                                color: Colors.black,
                                icon: const Icon(
                                  Icons.image,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text("From Gallery")
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
          : _image == null
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
                      image: MemoryImage(_image!),
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
    setState(() => _image = newImage);
    if (!mounted) return;
    navigator.pop();
  }

  Widget _buildTextFieldForm({
    String? hintText,
    int? maxLines,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 12),
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: 12,
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

  Widget _buildFormInputWeight({
    TextEditingController? controller,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppColors.main,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondary,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            TextField(
              controller: controller,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.end,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                constraints: BoxConstraints(maxHeight: 30),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 30,
              ),
              child: DropdownSearch<String>(
                decoratorProps: DropDownDecoratorProps(
                  baseStyle: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                    filled: true,
                    fillColor: AppColors.main,
                  ),
                ),
                selectedItem: selectedUnit,
                items: (filter, infiniteScrollProps) => units,
                suffixProps: const DropdownSuffixProps(
                  dropdownButtonProps: DropdownButtonProps(
                    padding: EdgeInsets.zero,
                    iconClosed: Icon(Icons.keyboard_arrow_down),
                    iconOpened: Icon(Icons.keyboard_arrow_up),
                  ),
                ),
                popupProps: PopupProps.menu(
                  itemBuilder: (context, item, isDisabled, isSelected) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        item.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                  fit: FlexFit.loose,
                  showSearchBox: true,
                  searchDelay: Duration.zero,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
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
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
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

                StorageItem newItem = widget.item.copyWith(
                  image: _image != null
                      ? await ImageService.uploadImage(_image!)
                      : null,
                  name: nameController.text,
                  currentWeight: widget.item.currentWeight,
                  maxWeight: double.tryParse(weightController.text),
                  unit: selectedUnit,
                  description: descriptionController.text,
                );
                await _storageItemService.updateStorageItem(newItem);
                await _storageItemService.updateToStoreItem(newItem);

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
                  : const Text("Save"),
            ),
          ),
          const SizedBox(width: 5),
          Hero(
            tag: 'fab-icon-add',
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
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
