import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'user_trigger.model.dart';

class TriggerDeviceStore extends ChangeNotifier {
  List<UserTrigger> _list;
//  Map<int, UserTrigger> _map;
  UnmodifiableListView<UserTrigger> _readonlyList;
//  UnmodifiableMapView<int, UserTrigger> _readonlyMap;

  UnmodifiableListView<UserTrigger> get list => _readonlyList;
//  UnmodifiableMapView<int, UserTrigger> get map => _readonlyMap;

  setList(List<UserTrigger> list) {
    _list = list;
    _readonlyList = UnmodifiableListView(_list);
//    _readonlyMap = UnmodifiableMapView<int, UserTrigger>(Map.fromIterable(_readonlyList,
//      key: (d) => d.triggerDeviceId,
//      value: (d) => d,
//    ));

    notifyListeners();
  }
}