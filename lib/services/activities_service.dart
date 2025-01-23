import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koda/models/activity_model.dart';

class ActivitiesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _tableName = "activities";

  Future<String?> createActivities(Activity activity) async {
    String? id;
    try {
      await _firestore
          .collection(_tableName)
          .add(activity.toFirestore())
          .then(
        (doc) => id = doc.id,
      );
    } catch (_) {}

    return id;
  }

  Stream<List<Activity>> getActivities({
    String searchField = "",
    DateTime? pickedDate,
  }) {
    DateTime? startOfDay, endOfDay;
    if (pickedDate != null) {
      startOfDay =
          DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 0, 0, 0);
      endOfDay = DateTime(
          pickedDate.year, pickedDate.month, pickedDate.day, 23, 59, 59);
    }
    try {
      return _firestore
          .collection(_tableName)
          .orderBy("timestamp", descending: true)
          .where(
            "timestamp",
            isGreaterThanOrEqualTo: startOfDay,
            isLessThanOrEqualTo: endOfDay,
          )
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Activity.fromFirestore(doc);
        }).where((activity) {
          final status = (activity.status ?? "").toLowerCase();
          final details = (activity.details?.toString() ?? "").toLowerCase();
          final search = searchField.toLowerCase();

          return status.contains(search) || details.contains(search);
        }).toList();
      });
    } catch (_) {}

    return const Stream.empty();
  }

  Future<void> deleteActivity(Activity activity) async {
    await _firestore.collection(_tableName).doc(activity.id).delete();
  }
}
