import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koda/models/storage_item_model.dart';
import 'package:koda/models/store_item_model.dart';
import 'package:koda/services/storage_item_service.dart';

class StoreItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _tableName = "store_item";

  Future<void> createStoreItem(StoreItem storeItem) async {
    try {
      await updateToStorageItem(storeItem);
      await _firestore
          .collection(_tableName)
          .doc()
          .set(storeItem.toFirestore());
    } catch (_) {}
  }

  Stream<List<StoreItem>> getStoreItems({
    String searchField = "",
    String label = "All",
  }) {
    try {
      return _firestore
          .collection(_tableName)
          .orderBy("timestamp", descending: false)
          .where("category", isEqualTo: label == "All" ? null : label)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              return StoreItem.fromFirestore(doc);
            })
            .where((storeItem) => (storeItem.name ?? "")
                .toLowerCase()
                .contains(searchField.toLowerCase()))
            .toList();
      });
    } catch (_) {}

    return const Stream.empty();
  }

  Future<List<String>> getStoreCategories() async {
    try {
      final snapshot = await _firestore
          .collection(_tableName)
          .orderBy("category", descending: false)
          .get();
      final categorySet = <String>{};

      for (var doc in snapshot.docs) {
        final data = doc.data()["category"];
        if (data != null && data is String && data.isNotEmpty) {
          categorySet.add(data);
        }
      }

      return categorySet.toList();
    } catch (_) {}

    return [];
  }

  Future<void> updateStoreItem(StoreItem storeItem) async {
    try {
      await _firestore
          .collection(_tableName)
          .doc(storeItem.id)
          .update(storeItem.toFirestore());
    } catch (_) {}
  }

  Future<void> updateToStorageItem(StoreItem storeItem) async {
    final StorageItemService storageItemService = StorageItemService();

    final List<StorageItem> storageItems = await storageItemService.getStorageItemsList();
    await Future.wait(storageItems.map((storageItem) async {

      final currentItems = storageItem.useForStoreItem ?? [];
      final updatedItems = currentItems.where((element) => element != storeItem.id);
      await storageItemService.updateStorageItem(
        storageItem.copyWith(useForStoreItem: updatedItems.toList()),
      );
    }).toList());

    await Future.wait((storeItem.usedStorageItems ?? []).map((e) async {
      StorageItem? storageItem =
          await storageItemService.getStorageItem(e["id"]);
      if (storageItem == null) return;

      final currentItems = storageItem.useForStoreItem ?? [];
      final updatedItems = {...currentItems, storeItem.id!};

      await storageItemService.updateStorageItem(
        storageItem.copyWith(useForStoreItem: updatedItems.toList()),
      );
    }).toList());
  }

  Future<void> deleteStoreItem(StoreItem storeItem) async {
    try {
      final StorageItemService storageItemService = StorageItemService();

      await Future.wait((storeItem.usedStorageItems ?? []).map((e) async {
        StorageItem? storageItem =
            await storageItemService.getStorageItem(e["id"]);
        if (storageItem == null) return;

        final currentItems = storageItem.useForStoreItem ?? [];
        final updatedItems =
            currentItems.where((item) => item != storeItem.id).toList();

        await storageItemService.updateStorageItem(
          storageItem.copyWith(useForStoreItem: updatedItems.toList()),
        );
      }).toList());

      await _firestore.collection(_tableName).doc(storeItem.id).delete();
    } catch (_) {}
  }

  Future<void> undoDeleteItem(StoreItem storeItem) async {
    await createStoreItem(storeItem);
  }

  Future<StoreItem?> getStoreItem(String id) async {
    try {
      final snapshot = await _firestore.collection(_tableName).doc(id).get();
      return StoreItem.fromJSON(snapshot.data() ?? {}, id);
    } catch (_) {}

    return null;
  }
}