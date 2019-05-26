import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:newcmms_flutter/services/http_client.service.dart';

import 'user_trigger.model.dart';

class UserTriggerRepository extends ChangeNotifier {
  final HttpClient _httpClient;
  
  List<UserTrigger> _list;
//  Map<int, UserTrigger> _map;
  UnmodifiableListView<UserTrigger> _readonlyList;
//  UnmodifiableMapView<int, UserTrigger> _readonlyMap;
  Future<UnmodifiableListView<UserTrigger>> _listFuture;

  UnmodifiableListView<UserTrigger> get list => _readonlyList;
//  UnmodifiableMapView<int, UserTrigger> get map => _readonlyMap;
  
  UserTriggerRepository(this._httpClient);

  Future<UnmodifiableListView<UserTrigger>> refresh() async {
    if (_listFuture != null) {
      return _listFuture;
    }
    _listFuture = _loadList();
    _listFuture.whenComplete(() => _listFuture = null);
    return _listFuture;
  }

  Future<UnmodifiableListView<UserTrigger>> _loadList() async {
    _setList(await _httpClient.getUserTriggers());
    return _readonlyList;
  }

  _setList(List<UserTrigger> list) {
    _list = list;
    _readonlyList = UnmodifiableListView(_list);
//    _readonlyMap = UnmodifiableMapView<int, UserTrigger>(Map.fromIterable(_readonlyList,
//      key: (d) => d.userTriggerId,
//      value: (d) => d,
//    ));

    notifyListeners();
  }
}