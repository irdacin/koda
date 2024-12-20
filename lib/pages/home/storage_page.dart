import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:koda/components/filter_chip_section.dart';
import 'package:koda/components/form_item_dialog.dart';
import 'package:koda/components/search_bar_field.dart';
import 'package:koda/helpers/app_colors.dart';
import 'package:koda/pages/home/settings_page.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> with WidgetsBindingObserver {
  final TextEditingController quantityController = TextEditingController(text: "0");
  final Map<int, TextEditingController> itemControllers = {};

  Map<int, int> quantity = {};
  final List<String> units = ["Kilogram (kg)", "Ton", "G", "A"];

  bool isEdit = false;
  bool openDialog = false;
  int indexDelete = -1;
  bool isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboardState();
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
      chipLabels: const [
        Text("All"),
        Text("Full"),
        Text("> 50 %"),
        Text("< 50 %"),
        Text("Empty"),
      ],
      onSelected: (value) {
        print(value);
      },
      backgroundColor: AppColors.secondary,
      selectedColor: AppColors.selected,
      selectedLabelColor: AppColors.secondaryText,
    );
  }

  Widget _buildStorageLists() {
    return Expanded(
      child: SlidableAutoCloseBehavior(
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemCount: 2,
          padding: const EdgeInsets.only(bottom: 250),
          itemBuilder: (context, index) {
            return Slidable(
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.3,
                children: [
                  SlidableAction(
                    onPressed: (context) => _deleteItem(index),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    label: "Delete",
                  ),
                ],
              ),
              child: _buildStorageItem(index: index),
            );
          },
        ),
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

  void _showItemDialog() async {
    setState(() => openDialog = true);
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return FormItemDialog(
          children: [
            _buildImageForm(context),
            const SizedBox(height: 15),
            _buildTextFieldForm(hintText: "Product Name"),
            const SizedBox(height: 15),
            _buildTextFieldForm(hintText: "Product Category"),
            const SizedBox(height: 15),
            _buildFormInputQuantity(),
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

  Widget _buildImageForm(BuildContext context) {
    return Container(
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

  Widget _buildFormInputQuantity() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppColors.main,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondary,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            TextField(
              controller: quantityController,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.end,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
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
                  baseStyle: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Choose Storage Item",
                    hintStyle: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    filled: true,
                    fillColor: AppColors.main,
                  ),
                ),
                selectedItem: "Kilogram (kg)",
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
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  },
                  fit: FlexFit.loose,
                  showSearchBox: true,
                  searchDelay: Duration.zero,
                  searchFieldProps: TextFieldProps(
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
          ],
        ),
      ),
    );
  }

  Widget _buildStorageItem({
    required int index,
  }) {
    String title = "Coffee Bean";
    double currentWeight = 20;
    double maxWeight = 20;
    double percentage = currentWeight / maxWeight;
    String unit = "Kg";

    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: Icon(
                Icons.edit,
              ),
            )
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "$title ${index + 1}",
                      style: const TextStyle(
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (isEdit) ...[
                    Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        border: Border.all(color: AppColors.secondary)
                      ),
                      child: TextField(
                        controller: itemControllers.putIfAbsent(index, () => TextEditingController(
                          text: quantity.containsKey(index) ? quantity[index].toString() : "0",
                        )),
                        onChanged: (value) {
                          quantity[index] = int.parse(value);
                        },
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
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
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        border: Border.all(color: AppColors.secondary)
                      ),
                      child: Text("Ton", style: TextStyle(fontSize: 12),),
                    ),
                  ]
                ],
              ),
              SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffe0e0e0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Container(
                    height: 8,
                    width:
                        percentage * (MediaQuery.of(context).size.width - 150),
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
                    '${currentWeight.toInt()} $unit',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '${maxWeight.toInt()} $unit',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  void _deleteItem(int index) {
    setState(() => indexDelete = -1);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text(
        "1 storage item deleted",
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
