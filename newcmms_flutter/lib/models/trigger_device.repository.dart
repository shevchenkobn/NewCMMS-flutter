import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:newcmms_flutter/services/http_client.service.dart';

import 'trigger_device.model.dart';

class TriggerDeviceRepository extends ChangeNotifier {
  final HttpClient _httpClient;

  List<TriggerDevice> _list;
  Map<int, TriggerDevice> _map;
  UnmodifiableListView<TriggerDevice> _readonlyList;
  UnmodifiableMapView<int, TriggerDevice> _readonlyMap;
  Future<UnmodifiableListView<TriggerDevice>> _listFuture;
  Future<TriggerDevice> _deviceFuture;

  UnmodifiableListView<TriggerDevice> get list => _readonlyList;
  UnmodifiableMapView<int, TriggerDevice> get map => _readonlyMap;

  TriggerDeviceRepository(this._httpClient);

  Future<UnmodifiableListView<TriggerDevice>> refresh() async {
    if (_listFuture != null) {
      return _listFuture;
    }
    _listFuture = _loadList();
    _listFuture.whenComplete(() => _listFuture = null);
    return _listFuture;
  }

  Future<TriggerDevice> refreshOne(int triggerDeviceId) async {
    if (_deviceFuture != null) {
      return _deviceFuture;
    }
    _deviceFuture = _loadOneDevice(triggerDeviceId);
    _deviceFuture.whenComplete(() => _deviceFuture = null);
    return _deviceFuture;
  }

  Future<UnmodifiableListView<TriggerDevice>> _loadList() async {
    _setList(await _httpClient.getTriggerDevices(growableList: false));
    return _readonlyList;
  }

  Future<TriggerDevice> _loadOneDevice(int triggerDeviceId) async {
    final device = await _httpClient.getTriggerDevice(triggerDeviceId);
    if (_list == null) {
      _setList([device]);
    } else {
      final index = _list.indexOf(device);
      if (index < 0) {
        _list.add(device);
      } else {
        _list[index] = device;
      }
      _map[device.triggerDeviceId] = device;
      notifyListeners();
    }
    return device;
  }

  void _setList(List<TriggerDevice> devices) {
    _list = devices;

    _readonlyList = UnmodifiableListView(_list);
    _map = Map.fromIterable(_readonlyList,
      key: (d) => d.triggerDeviceId,
      value: (d) => d,
    );
    _readonlyMap = UnmodifiableMapView(_map);

    notifyListeners();
  }
}
