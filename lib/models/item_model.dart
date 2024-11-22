class Item {
  final int? id;
  final String? name;
  final double? weight;
  final String? description;
  final bool isSelected;

  Item({
    this.id,
    this.name,
    this.weight,
    this.description,
    this.isSelected = false
  });

  factory Item.fromDatabase(Map<String, dynamic> db) => Item(
    id: db["id"],
    name: db["name"],
    weight: db["weight"],
    description: db["description"],
  );

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'description': description,
    };
  }
}