import 'package:flutter/material.dart';
import 'package:koda/database/database_item.dart';
import 'package:koda/models/item_model.dart';
import 'package:koda/pages/home/widget/form_item_page.dart';

Widget Home() {
  DatabaseItem db = DatabaseItem();

  return FutureBuilder(
    future: db.read(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(
          child: Text("Terjadi Error pada server"),
        );
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Flexible(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: Colors.blue),
          ),
        );
      }

      if (snapshot.hasData) {
        return Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search"
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 24),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Item item = snapshot.data![index];
                      return Stack(
                        children: [
                          Card(
                            color: const Color(0xffd7d7d7),
                            child: ListTile(
                              onTap: () {
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => ItemDetailPage(
                                //       item: item,
                                //     ),
                                //   ),
                                // );
                              },
                              leading: Container(
                                width: 70,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                item.name ?? "Folder",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              subtitle: Text(
                                item.description ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => FormItemPage(
                                      item: item,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container();
    },
  );
}
