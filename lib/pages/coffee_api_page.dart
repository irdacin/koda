import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koda/helper/url_helper.dart';
import 'package:koda/models/coffee_model.dart';
import 'package:koda/pages/coffee_detail_page.dart';

class CoffeeApiPage extends StatelessWidget {
  const CoffeeApiPage({super.key});

  Future<List<Coffee>> getCoffee() async {
    var response = await http.get(Uri.parse(UrlHelper.baseUrl));
    List resJson = json.decode(response.body);
    List<Coffee> coffee = resJson.map((e) => Coffee.fromJson(e)).toList();
    return coffee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coffee API"),
      ),
      body: FutureBuilder(
        future: getCoffee(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Fetch Error"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (snapshot.hasData) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio:
                      (MediaQuery.of(context).size.width / 3 - 50) / 150,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Coffee coffee = snapshot.data![index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CoffeeDetailPage(
                          id: coffee.coffeeId,
                        ),
                      ));
                    },
                    child: Column(
                      children: [
                        Hero(
                          tag: coffee.coffeeId,
                          child: ClipRRect(
                            child: Image.network(
                              coffee.imageUrl,
                              fit: BoxFit.cover,
                              height: 150,
                              width: MediaQuery.of(context).size.width / 3 - 50,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  coffee.name,
                                  style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "\$${coffee.price.toString()}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
