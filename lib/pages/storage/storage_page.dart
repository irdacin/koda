import 'package:flutter/material.dart';
import 'package:koda/pages/storage/add_item_storage_page.dart';

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Color(0xffd9d9d9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Burger ${index + 1}"),
                      SizedBox(height: 5),
                      Text("70%"),
                      SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: 70 / 100,
                        color: Colors.green,
                        backgroundColor: Color(0xffe0e0e0),
                        minHeight: 16,
                        borderRadius: BorderRadius.circular(10),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: const Color(0xffd9d9d9),
            onPressed: () {},
            heroTag: null,
            child: const Icon(Icons.edit, size: 30),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            backgroundColor: const Color(0xffd9d9d9),
            heroTag: null,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: AddItemStoragePage(),
                  );
                },
              );
            },
            child: const Icon(Icons.add, size: 35),
          ),
        ],
      ),
    );
  }
}
