import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:deep_collection/deep_collection.dart';

abstract class Editable<T> {
  String id;
  Editable(this.id, this.isSelected);
  bool isSelected;
  Map<String, dynamic> toMap();
  void fromMap(Map map);
  T clone();
}

class Editor<T extends Editable<T>> {
  late T _original;
  late final T edit;
  final void Function(T) _setItem;
  late final FutureOr<Map> Function(Map) _doUpdate;
  Editor(T editable, this._doUpdate, this._setItem) {
    _original = editable;
    edit = _original.clone();
  }
  Future<void> update() async {
    Map<String, dynamic> originalMap = _original.toMap();
    Map<String, dynamic> editMap = edit.toMap();
    Map difference = originalMap.deepDifferenceByValue(editMap);
    if (difference.isEmpty) return;
    Map result = await _doUpdate(difference);
    _original.fromMap(result);
    _setItem(_original);
  }
}

abstract class ItemsModel<T extends Editable<T>> with ChangeNotifier {
  /// The key is item's id.
  Map<String, T> itemsMap = {};

  void clearItems() {
    itemsMap = {};
    notifyListeners();
  }

  /// Get all selected items.
  Iterable<T> get selectedItems =>
      itemsMap.values.where((item) => item.isSelected);

  /// Get selected item. If selectedItems length != 1, then return null.
  T? get selectedItem {
    if (selectedItems.length != 1) return null;
    return selectedItems.first;
  }

  /// Set all items is selected or not.
  void setAllItemsSelected(bool isSelected) {
    for (T item in itemsMap.values) {
      item.isSelected = isSelected;
      itemsMap[item.id] = item.clone();
    }
    notifyListeners();
  }

  /// Set item in itemsMap.
  void setItem(T item) {
    itemsMap[item.id] = item.clone();
    notifyListeners();
  }

  Editor<T> getEditor(T item);
}
