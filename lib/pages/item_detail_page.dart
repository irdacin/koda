import 'package:flutter/material.dart';
import 'package:koda/models/item_model.dart';
import 'package:koda/pages/widget/item_detail.dart';
import 'package:koda/pages/widget/side_bar.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;
  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [ 
            ItemDetail(item: item),
            SideBar(),
          ],
        ),
      ),
    );
  }
}