import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:deep_collection/deep_collection.dart';

abstract class Editable<T> {
  String id;
  void Function() notifyListeners;
  Editable(this.id, this.notifyListeners);
  Map<String, dynamic> toMap();

  @protected
  @mustCallSuper
  void fromMap(Map map) {
    notifyListeners();
  }

  T clone();
}

mixin Selectalbe<T> on Editable<T> {
  bool _selected = false;
  bool get selected => _selected;
  set selected(bool value) {
    _selected = value;
    notifyListeners();
  }
}

abstract class Editor<T extends Editable<T>> {
  late T _original;
  late final T edit;
  late final FutureOr<Map> Function(Map) _doUpdate;
  Editor(T editable, this._doUpdate) {
    _original = editable;
    edit = _original.clone();
  }
  Future<void> update() async {
    Map<String, dynamic> originalMap = _original.toMap();
    Map<String, dynamic> editMap = edit.toMap();
    Map difference = editMap.deepDifferenceByValue(originalMap);
    if (difference.isEmpty) return;
    Map result = await _doUpdate(difference);
    _original.fromMap(result);
  }
}

abstract class ItemsModel<T extends Editable> with ChangeNotifier {
  /// The key is item's id.
  Map<String, T> itemsMap = {};
}
