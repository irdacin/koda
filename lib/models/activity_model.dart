import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String? id;
  final String? status;
  final dynamic details;
  final DateTime timestamp;

  Activity({
    this.id,
    this.status,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Activity.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Activity(
      id: snapshot.id,
      status: data['status'] as String?,
      details: data['details'] is List
          ? (data['details'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList()
          : data['details'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'status': status,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  Activity copyWith({
    String? id,
    String? status,
    dynamic details,
    DateTime? timestamp,
  }) {
    return Activity(
      id: id ?? this.id,
      status: status ?? this.status,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
