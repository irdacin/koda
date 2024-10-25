import 'package:flutter/material.dart';
import 'package:koda/database/database_item.dart';
import 'package:koda/models/item_model.dart';
import 'package:provider/provider.dart';

class FormItemPage extends StatefulWidget {
  final Item? item;
  const FormItemPage({super.key, this.item});

  @override
  State<FormItemPage> createState() => _FormItemPageState();
}

class _FormItemPageState extends State<FormItemPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.item?.name ?? "";
    weightController.text = widget.item?.weight.toString() ?? "";
    descriptionController.text = widget.item?.description ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xffd9d9d9)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          alignment: Alignment.center,
                          child: const Text(
                            "Picture",
                            style: TextStyle(
                                fontSize: 18, color: Color(0xff636c72)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                              hintText: "name",
                              filled: true,
                              fillColor: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "weight",
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "description",
                            ),
                            minLines: 4,
                            maxLines: null),
                        const SizedBox(height: 24),
                        ElevatedButton(
                            onPressed: () {
                              Item newItem = Item(
                                  id: widget.item?.id,
                                  name: nameController.text,
                                  weight: double.parse(weightController.text),
                                  description: descriptionController.text);

                              if (widget.item case _?) {
                                Provider.of<DatabaseItem>(context,
                                        listen: false)
                                    .update(newItem);
                              } else {
                                Provider.of<DatabaseItem>(context,
                                        listen: false)
                                    .insert(newItem);
                              }

                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(double.infinity, 0),
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Done"))
                      ],
                    ),
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
          ),
        ),
      ),
    );
  }
}
