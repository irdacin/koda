class Coffee {
  String id;
  int coffeeId;
  String name;
  String description;
  double price;
  String region;
  int weight;
  List<String> flavorProfile;
  List<String> grindOption;
  int roastLevel;
  String imageUrl;

  Coffee({
    required this.id,
    required this.coffeeId,
    required this.name,
    required this.description,
    required this.price,
    required this.region,
    required this.weight,
    required this.flavorProfile,
    required this.grindOption,
    required this.roastLevel,
    required this.imageUrl,
  });

  factory Coffee.fromJson(Map<String, dynamic> json) => Coffee(
        id: json["_id"],
        coffeeId: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"]?.toDouble(),
        region: json["region"],
        weight: json["weight"],
        flavorProfile: List<String>.from(json["flavor_profile"].map((x) => x)),
        grindOption: List<String>.from(json["grind_option"].map((x) => x)),
        roastLevel: json["roast_level"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "id": coffeeId,
        "name": name,
        "description": description,
        "price": price,
        "region": region,
        "weight": weight,
        "flavor_profile": List<dynamic>.from(flavorProfile.map((x) => x)),
        "grind_option": List<dynamic>.from(grindOption.map((x) => x)),
        "roast_level": roastLevel,
        "image_url": imageUrl,
      };
}
