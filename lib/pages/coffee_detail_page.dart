import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koda/helper/url_helper.dart';
import 'package:koda/models/coffee_model.dart';
import 'package:koda/pages/widget/coffee_detail.dart';

class CoffeeDetailPage extends StatelessWidget {
  final int id;
  const CoffeeDetailPage({super.key, required this.id});

  Future<Coffee> getCoffee() async {
    var response = await http.get(Uri.parse("${UrlHelper.baseUrl}/$id"));
    List resJson = json.decode(response.body);
    Coffee coffee = Coffee.fromJson(resJson.first);
    return coffee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Coffee>(
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
            return CoffeeDetail(coffee: snapshot.data!);
          }

          return Container();
        },
      ),
    );
  }
}
