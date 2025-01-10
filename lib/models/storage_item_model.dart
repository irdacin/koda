import 'package:cloud_firestore/cloud_firestore.dart';

class StorageItem {
  final String? id;
  final String? image;
  final String? name;
  final double? currentWeight;
  final double? maxWeight;
  final double? percentage;
  final List<Map<String, dynamic>>? useForStoreItem;
  final String? unit;
  final String? description;
  final DateTime timestamp;

  StorageItem({
    this.id,
    this.image,
    this.name,
    this.currentWeight = 0,
    this.maxWeight = 1,
    this.useForStoreItem = const [],
    this.unit,
    this.description,
    double? percentage,
    DateTime? timestamp,
  })  : timestamp = timestamp ?? DateTime.now(),
        percentage = currentWeight! / maxWeight!;

  factory StorageItem.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return StorageItem(
      id: snapshot.id,
      image: data['image'],
      name: data['name'],
      currentWeight: data['currentWeight'],
      maxWeight: data['maxWeight'],
      percentage: data['percentage'],
      useForStoreItem: data['useForStoreItem'] != null
          ? List<Map<String, dynamic>>.from(data['useForStoreItem'].map(
              (item) => Map<String, dynamic>.from(item),
            ))
          : null,
      unit: data['unit'],
      description: data['description'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  factory StorageItem.fromJSON(Map<String, dynamic> data, String id) {
    return StorageItem(
      id: id,
      image: data['image'],
      name: data['name'],
      currentWeight: data['currentWeight'],
      maxWeight: data['maxWeight'],
      percentage: data['percentage'],
      useForStoreItem: data['useForStoreItem'] != null
          ? List<Map<String, dynamic>>.from(data['useForStoreItem'].map(
              (item) => Map<String, dynamic>.from(item),
            ))
          : null,
      unit: data['unit'],
      description: data['description'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'image': image,
      'name': name,
      'currentWeight': currentWeight,
      'maxWeight': maxWeight,
      'percentage': percentage,
      'unit': unit,
      'useForStoreItem': useForStoreItem?.map((item) {
        return {
          "id": item["id"],
          "name": item["name"],
        };
      }).toList(),
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp)
    };
  }

  StorageItem copyWith({
    String? id,
    String? image,
    String? name,
    double? currentWeight,
    double? maxWeight,
    double? percentage,
    List<Map<String, dynamic>>? useForStoreItem,
    String? unit,
    String? description,
    DateTime? timestamp,
  }) {
    return StorageItem(
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      currentWeight: currentWeight ?? this.currentWeight,
      maxWeight: maxWeight ?? this.maxWeight,
      percentage: percentage ?? this.percentage,
      useForStoreItem: useForStoreItem ?? this.useForStoreItem,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
