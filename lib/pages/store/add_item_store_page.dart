import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class AddItemStorePage extends StatefulWidget {
  const AddItemStorePage({super.key});

  @override
  State<AddItemStorePage> createState() => _AddItemStorePageState();
}

class _AddItemStorePageState extends State<AddItemStorePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xffd9d9d9),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Name",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "description",
                  ),
                  minLines: 3,
                  maxLines: null,
                ),
                const SizedBox(height: 24),
                DropdownSearch<String>(
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "choose / add categories",
                    ),
                  ),
                  items: (filter, infiniteScrollProps) =>
                      ["Kg", "Ton", "G", "A"],
                  suffixProps: const DropdownSuffixProps(
                    dropdownButtonProps: DropdownButtonProps(
                      iconClosed: Icon(Icons.keyboard_arrow_down),
                      iconOpened: Icon(Icons.keyboard_arrow_up),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(item),
                      );
                    },
                    fit: FlexFit.loose,
                    showSearchBox: true,
                    menuProps: const MenuProps(
                      margin: EdgeInsets.only(top: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Item newItem = Item(
                    //   id: widget.item?.id,
                    //   name: nameController.text,
                    //   weight: double.parse(weightController.text),
                    //   description: descriptionController.text,
                    // );

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 0),
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("SAVE"),
                )
              ],
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                // Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
