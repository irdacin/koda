import 'package:flutter/material.dart';
import 'package:koda/pages/store/add_item_store_page.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GridView.builder(
          itemCount: 5,
          padding: EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xffd9d9d9),
                borderRadius: BorderRadius.circular(20)
              ),
            );
          },
        ),
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
                    child: AddItemStorePage(),
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
