import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koda/components/filter_chip_section.dart';
import 'package:koda/components/form_item_dialog.dart';
import 'package:koda/components/search_bar_field.dart';
import 'package:koda/helpers/app_colors.dart';
import 'package:koda/pages/home/settings_page.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with WidgetsBindingObserver {
  TextEditingController quantityController = TextEditingController(text: "0");
  String selectedStorageUnit = "kg";
  List<String> storageItems = ["Kg", "Ton", "G", "A"];
  bool isExpand = false;

  bool isEdit = false;
  bool openDialog = false;
  int indexDelete = -1;
  bool isKeyboardOpen = false;

  final dropdownItems = ["Makanan", "Minuman"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    quantityController.dispose();
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
    setState(() => isKeyboardOpen = keyboardVisible);
  }

  void _onKeyboardDismiss() {
    FocusScope.of(context).unfocus();
    setState(() => indexDelete = -1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onKeyboardDismiss,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildBody(),
            Positioned(
              right: 15,
              bottom: 100,
              child:
                  !isKeyboardOpen ? _buildFloatingActions() : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: SearchBarField(
        onSearchChanged: (value) {},
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
        const Text("All"),
        DropdownSearch<String>(),
      ],
      dropdownItem: [
        "Kg",
        "g",
        "aag",
      ],
      onSelected: (value) {
        print(value);
      },
      backgroundColor: AppColors.secondary,
      selectedColor: AppColors.selected,
      selectedIconColor: AppColors.main,
      selectedLabelColor: AppColors.secondaryText,
    );
  }

  Widget _buildStoreLists() {
    return Expanded(
      child: AlignedGridView.count(
        itemCount: 10,
        padding: const EdgeInsets.only(bottom: 250),
        crossAxisCount: 2,
        mainAxisSpacing: 30,
        crossAxisSpacing: 30,
        itemBuilder: (context, index) {
          return _buildStoreItem(index: index);
        },
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor: isEdit ? AppColors.selected : AppColors.secondary,
          onPressed: () {
            setState(() => isEdit ^= true);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          heroTag: null,
          child: Icon(
            isEdit ? FontAwesomeIcons.check : FontAwesomeIcons.penToSquare,
            size: 25,
            color: isEdit ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        FloatingActionButton(
          backgroundColor: isEdit ? Colors.red : AppColors.secondary,
          heroTag: null,
          onPressed: isEdit ? _closeEditItem : _showItemDialog,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: openDialog ? 0 : null,
          child: Hero(
            tag: 'fab-icon-add',
            child: Icon(
              isEdit ? FontAwesomeIcons.xmark : FontAwesomeIcons.plus,
              size: 25,
              color: isEdit ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _showItemDialog({
    Uint8List? image,
    String? name,
    String? category,
    String? description,
  }) async {
    setState(() => openDialog = true);
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return FormItemDialog(
          children: [
            _buildImageForm(context, setState, image: image),
            const SizedBox(height: 15),
            _buildTextFieldForm(hintText: "Product Name"),
            const SizedBox(height: 15),
            _buildTextFieldForm(hintText: "Product Category"),
            const SizedBox(height: 15),
            _buildFormSelectedStorageItem(context, setState),
            const SizedBox(height: 15),
            _buildTextFieldForm(hintText: "Description", maxLines: 3),
          ],
        );
      }),
    );
    setState(() => openDialog = false);
  }

  void _closeEditItem() {
    setState(() => isEdit = false);
  }

  Widget _buildImageForm(
    BuildContext context,
    StateSetter setState, {
    Uint8List? image,
  }) {
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
                          onPressed: () async {
                            Navigator.of(context).pop();

                            XFile? pickedFile = await ImagePicker().pickImage(
                              source: ImageSource.camera,
                            );

                            Uint8List newImage =
                                await pickedFile!.readAsBytes();
                            setState(() {
                              image = newImage;
                            });
                          },
                          color: Colors.black,
                          icon: const Icon(
                            Icons.camera_alt,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Take Picture",
                      )
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
                          onPressed: () async {
                            Navigator.of(context).pop();
                            XFile? pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);

                            Uint8List newImage =
                                await pickedFile!.readAsBytes();
                            setState(() {
                              image = newImage;
                            });
                          },
                          color: Colors.black,
                          icon: const Icon(
                            Icons.image,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "From Gallery",
                      )
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
                  image: MemoryImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }

  Widget _buildTextFieldForm({
    String? hintText,
    int? maxLines,
  }) {
    return TextField(
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

  Widget _buildFormSelectedStorageItem(
    BuildContext context,
    StateSetter setState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.main,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: AppColors.main,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    blurStyle: BlurStyle.solid,
                    color: AppColors.secondary,
                    offset: Offset(0.0, 1.0),
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
                      child: DropdownSearch<String>(
                        decoratorProps: DropDownDecoratorProps(
                          baseStyle: TextStyle(
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
                            hintText: "Choose Storage Item",
                            hintStyle: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 10,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 5),
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
                        popupProps: PopupProps.menu(
                          itemBuilder: (context, item, isDisabled, isSelected) {
                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                item.toString(),
                                style: TextStyle(fontSize: 12),
                              ),
                            );
                          },
                          fit: FlexFit.loose,
                          showSearchBox: true,
                          searchDelay: Duration.zero,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
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
                              constraints: BoxConstraints(maxHeight: 30),
                            ),
                            style: TextStyle(fontSize: 12),
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
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: quantityController,
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        constraints: BoxConstraints(maxHeight: 30),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 30,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppColors.main,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppColors.secondary),
                    ),
                    child: Text(
                      selectedStorageUnit,
                      style: TextStyle(
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  IconButton(
                    onPressed: () {
                      print("aaa");
                    },
                    padding: EdgeInsets.all(3),
                    constraints: BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                axisAlignment: -1,
                child: child,
              );
            },
            child: isExpand
                ? Column(
                    children: _buildSelectedStorageItem(),
                  )
                : const SizedBox(),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  isExpand ^= true;
                });
              },
              child: Icon(
                isExpand
                    ? Icons.keyboard_arrow_up_sharp
                    : Icons.keyboard_arrow_down_sharp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSelectedStorageItem() {
    return [
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.image),
            Text("Coffee Bean 1"),
            Text("16 g"),
            Icon(Icons.close)
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.image),
            Text("Coffee Bean 2"),
            Text("16 g"),
            Icon(Icons.close)
          ],
        ),
      ),
    ];
  }

  Widget _buildStoreItem({
    required int index,
  }) {
    bool isDelete = indexDelete == index;
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          GestureDetector(
            onLongPress: () => setState(() => indexDelete = index),
            child: Stack(
              children: [
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: isDelete
                      ? ElevatedButton(
                          onPressed: () => _deleteItem(index),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: AppColors.main,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          child: Text("Delete"),
                        )
                      : Icon(Icons.edit),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                axisAlignment: -1,
                child: child,
              );
            },
            child: isEdit
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.remove),
                      ),
                      Text(
                        "1",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add),
                      ),
                    ],
                  )
                : SizedBox(),
          )
        ],
      );
    });
  }

  void _deleteItem(int index) {
    setState(() => indexDelete = -1);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text(
        "1 store item deleted",
      ),
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
        label: "Undo",
        textColor: AppColors.selected,
        onPressed: () {},
      ),
    ));
  }
}
