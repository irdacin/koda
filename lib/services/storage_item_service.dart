import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koda/models/storage_item_model.dart';
import 'package:koda/models/store_item_model.dart';
import 'package:koda/services/store_item_service.dart';

class StorageItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _tableName = "storage_item";

  Future<void> createStorageItem(StorageItem storageItem) async {
    try {
      await updateToStoreItem(storageItem);
      await _firestore
          .collection(_tableName)
          .doc()
          .set(storageItem.toFirestore());
    } catch (_) {}
  }

  Stream<List<StorageItem>> getStorageItems({
    String searchField = "",
    String label = "All",
  }) {
    try {
      return _firestore
          .collection(_tableName)
          .orderBy("timestamp", descending: false)
          .where(
            "percentage",
            isEqualTo: label == "Full"
                ? 1
                : label == "Empty"
                    ? 0
                    : null,
            isLessThan: label == "< 50 %" ? 0.5 : null,
            isGreaterThan: label == "> 50 %" ? 0.5 : null,
          )
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => StorageItem.fromFirestore(doc))
            .where((storageItem) => (storageItem.name ?? "")
                .toLowerCase()
                .contains(searchField.toLowerCase()))
            .toList();
      });
    } catch (_) {}

    return const Stream.empty();
  }

  Future<void> updateStorageItem(StorageItem storageItem) async {
    try {
      await _firestore
          .collection(_tableName)
          .doc(storageItem.id)
          .update(storageItem.toFirestore());
    } catch (_) {}
  }

  Future<void> updateToStoreItem(StorageItem storageItem) async {
    final StoreItemService storeItemService = StoreItemService();

    final List<String> useForStoreItems = storageItem.useForStoreItem ?? [];
    for (String storeItemId in useForStoreItems) {
      StoreItem? storeItem = await storeItemService.getStoreItem(storeItemId);
      if (storeItem == null) continue;

      int index = storeItem.usedStorageItems
              ?.indexWhere((item) => item["id"] == storageItem.id) ??
          -1;

      if (index == -1) continue;
      final updatedItem = {
        ...storeItem.usedStorageItems![index],
        "image": storageItem.image,
        "name": storageItem.name,
        "unit": storageItem.unit,
      };
      storeItem.usedStorageItems![index] = updatedItem;

      await storeItemService.updateStoreItem(storeItem);
    }
  }

  Future<bool> deleteStorageItem(StorageItem storageItem) async {
    try {
      final List<String> useForStoreItems = storageItem.useForStoreItem ?? [];
      if (useForStoreItems.isNotEmpty) return false;

      await _firestore.collection(_tableName).doc(storageItem.id).delete();
      return true;
    } catch (_) {}

    return false;
  }

  Future<void> undoDeleteItem(StorageItem storageItem) async {
    await createStorageItem(storageItem);
  }

  Future<List<StorageItem>> getStorageItemsList() async {
    try {
      final snapshot = await _firestore
          .collection(_tableName)
          .orderBy("name", descending: false)
          .get();
      return snapshot.docs
          .map((doc) => StorageItem.fromFirestore(doc))
          .toList();
    } catch (_) {}

    return const [];
  }

  Future<StorageItem?> getStorageItem(String id) async {
    try {
      final snapshot = await _firestore.collection(_tableName).doc(id).get();
      return StorageItem.fromJSON(snapshot.data() ?? {}, id);
    } catch (_) {}

    return null;
  }
}
