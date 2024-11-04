import 'package:flutter/material.dart';
import 'package:koda/database/database_item.dart';
import 'package:koda/models/item_model.dart';
import 'package:koda/pages/form_item_page.dart';
import 'package:koda/pages/item_detail_page.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<DatabaseItem>(context).read(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Terjadi Error pada server"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasData) {
          return Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 24),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Item item = snapshot.data![index];
                    return Dismissible(
                      key: Key(index.toString()),
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        Provider.of<DatabaseItem>(
                          context,
                          listen: false,
                        ).delete(item.id!);
                      },
                      dismissThresholds: const {
                        DismissDirection.endToStart: 0.3
                      },
                      child: Stack(
                        children: [
                          Card(
                            color: const Color(0xffd7d7d7),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ItemDetailPage(item: item),
                                  ),
                                );
                              },
                              leading: Container(
                                width: 75,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                item.name ?? "Folder",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              subtitle: Text(
                                item.description,
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
                                      builder: (context) =>
                                          FormItemPage(item: item)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          );
        }

        return Container();
      },
    );
  }
}
