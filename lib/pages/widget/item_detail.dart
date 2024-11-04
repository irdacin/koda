import 'package:flutter/material.dart';
import 'package:koda/database/database_item.dart';
import 'package:koda/models/item_model.dart';
import 'package:provider/provider.dart';

class ItemDetail extends StatefulWidget {
  final Item item;
  const ItemDetail({super.key, required this.item});

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool _readOnly = true;

  @override
  void initState() {
    setState(() {
      
      nameController.text = widget.item.name ?? "Folder 1";
      weightController.text = widget.item.weight.toString();
      descriptionController.text = widget.item.description;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 15,
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 30,
                    )),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 25),
                    onEditingComplete: () {
                      setState(() {
                        Item newItem = Item(
                                  id: widget.item.id,
                                  name: nameController.text,
                                  weight: double.parse(weightController.text),
                                  description: descriptionController.text);
                                  Provider.of<DatabaseItem>(context,
                                        listen: false)
                                    .update(newItem);
                        _readOnly = true;
                      });
                    },
                    readOnly: _readOnly,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _readOnly = false;
                    });
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 30,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
