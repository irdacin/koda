import 'package:cloud_firestore/cloud_firestore.dart';

class StoreItem {
  final String? id;
  final String? image;
  final String? name;
  final String? category;
  final List<Map<String, dynamic>>? usedStorageItems;
  final String? description;
  final DateTime timestamp;

  StoreItem({
    this.id,
    this.image,
    this.name,
    this.category,
    this.usedStorageItems,
    this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory StoreItem.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return StoreItem(
      id: snapshot.id,
      image: data['image'],
      name: data['name'],
      category: data['category'],
      usedStorageItems: data['usedStorageItems'] != null
          ? List<Map<String, dynamic>>.from(data['usedStorageItems'].map(
              (item) => Map<String, dynamic>.from(item),
            ))
          : null,
      description: data['description'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  factory StoreItem.fromJSON(
      Map<String, dynamic> data, String id) {
    return StoreItem(
      id: id,
      image: data['image'],
      name: data['name'],
      category: data['category'],
      usedStorageItems: data['usedStorageItems'] != null
          ? List<Map<String, dynamic>>.from(data['usedStorageItems'].map(
              (item) => Map<String, dynamic>.from(item),
            ))
          : null,
      description: data['description'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'image': image,
      'name': name,
      'category': category,
      'usedStorageItems': usedStorageItems?.map((item) {
        return {
          "id": item["id"],
          "image": item["image"],
          "name": item["name"],
          "quantity": item["quantity"],
          "unit": item["unit"],
        };
      }).toList(),
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp)
    };
  }

  StoreItem copyWith({
    String? id,
    String? image,
    String? name,
    String? category,
    List<Map<String, dynamic>>? usedStorageItems,
    String? description,
    DateTime? timestamp,
  }) {
    return StoreItem(
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      category: category ?? this.category,
      usedStorageItems: usedStorageItems ?? this.usedStorageItems,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
