import 'package:flutter/material.dart';
import 'package:newcmms_flutter/utils/common.dart';
import '../di.dart';
import '../services/nfc_hce.service.dart';
import '../localizations.dart';

class NfcHcePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ModuleContainer.getDefault().get<NfcHcePageState>();
  }
}

class NfcHcePageState extends State<NfcHcePage> {
  final NfcHceService _nfcHceService;
  bool _isNfcEnabled;
  bool _isNfcServiceRunning;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snackbar;

  NfcHcePageState(this._nfcHceService)
      : _isNfcEnabled = null,
        _isNfcServiceRunning = null;

  @override
  void initState() {
    _loopRefresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }

  @override
  void dispose() {
    _hideSnackbar();
    super.dispose();
  }

  Future<void> _loopRefresh() async {
    while (true) {
      try {
        await _refresh();
        _setStateSafely();
        return;
      } catch (error, stackTrace) {
        _showUnknownError(error, stackTrace);
      }
    }
  }

  Future<void> _refresh() async {
    _isNfcEnabled = await _nfcHceService.isNfcEnabled();
    if (_isNfcEnabled) {
      _isNfcServiceRunning = await _nfcHceService.isNfcServiceRunning();
    }
  }

  void _setStateSafely({VoidCallback cb}) {
    if (mounted) {
      setState(cb ?? () {});
    }
  }

  void _showUnknownError(error, stackTrace) {
    print('NFC HCE page error:');
    print(error);
    print(stackTrace);
    final localization = AppLocalizations.of(context);
    _hideSnackbar();
    _snackbar = Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(localization.unknownError),
        duration: Duration(days: 10),
        action: SnackBarAction(
          label: localization.ok,
          onPressed: () {},
          textColor: Colors.redAccent,
        ),
      ),
    );
  }

  void _hideSnackbar() {
    if (_snackbar != null) {
      _snackbar.close();
      _snackbar = null;
    }
  }
}