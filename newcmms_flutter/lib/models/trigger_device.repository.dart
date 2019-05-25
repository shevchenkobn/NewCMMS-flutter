import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:newcmms_flutter/services/http_client.service.dart';

import 'trigger_device.model.dart';

class TriggerDeviceRepository extends ChangeNotifier {
  final HttpClient _httpClient;

  List<TriggerDevice> _list;
//  Map<int, TriggerDevice> _map;
  UnmodifiableListView<TriggerDevice> _readonlyList;
  UnmodifiableMapView<int, TriggerDevice> _readonlyMap;

  UnmodifiableListView<TriggerDevice> get list => _readonlyList;
  UnmodifiableMapView<int, TriggerDevice> get map => _readonlyMap;

  TriggerDeviceRepository(this._httpClient);

  Future<UnmodifiableListView<TriggerDevice>> refresh() async {
    _list = await _httpClient.getTriggerDevices(growableList: false);
    _readonlyList = UnmodifiableListView(_list);
    _readonlyMap = UnmodifiableMapView<int, TriggerDevice>(Map.fromIterable(_readonlyList,
      key: (d) => d.triggerDeviceId,
      value: (d) => d,
    ));

    notifyListeners();
    return _readonlyList;
  }

  Future<TriggerDevice> refreshOne(int triggerDeviceId) async {
    // TODO:
  }
}
