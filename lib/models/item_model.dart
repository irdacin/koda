class Item {
  final int? id;
  final String name;
  final double weight;
  final String description;

  Item({
    this.id,
    required this.name,
    required this.weight,
    required this.description
  });

  factory Item.fromDatabase(Map<String, dynamic> db) => Item(
    id: db["id"],
    name: db["name"],
    weight: db["weight"],
    description: db["description"],
  );
}