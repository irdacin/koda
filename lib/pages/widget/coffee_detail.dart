import 'package:flutter/material.dart';
import 'package:koda/models/coffee_model.dart';

class CoffeeDetail extends StatelessWidget {
  final Coffee coffee;
  const CoffeeDetail({super.key, required this.coffee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(coffee.name),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: coffee.coffeeId,
              child: SizedBox(
                height: 320,
                width: double.infinity,
                child: Image.network(
                  coffee.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(coffee.description),
            const SizedBox(height: 10),
            Text("Region: ${coffee.region}"),
            const SizedBox(height: 10),
            Text("Weight: ${coffee.weight}"),
            const SizedBox(height: 10),
            Text("Roast Level: ${coffee.roastLevel}"),
            const SizedBox(height: 10),
            Text("Price : \$${coffee.price}"),
          ],
        ),
      ),
    );
  }
}
