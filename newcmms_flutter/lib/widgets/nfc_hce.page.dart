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
  bool _isLoading;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snackbar;

  NfcHcePageState(this._nfcHceService)
      : _isNfcEnabled = null,
        _isNfcServiceRunning = null,
        _isLoading = false;

  @override
  void initState() {
    _loopRefresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).nfcTitle),
      ),
      body: _getViewportBody(),
    );
  }

  @override
  void dispose() {
    _hideSnackbar();
    super.dispose();
  }

  Widget _getViewportBody() {
    if (_isNfcEnabled == null) {
      return Align(
        alignment: Alignment(0, -0.3),
        child: CircularProgressIndicator(
          value: null,
        ),
      );
    } else if (_isLoading) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: _getBody()
          ),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: LinearProgressIndicator(
              value: null,
            )
          )
        ],
      );
    }
    return _getBody();
  }

  Widget _getBody() {
    return RefreshIndicator(
      onRefresh: () async {
        if (_isLoading) {
          return;
        }
        _refresh().then((devices) {
          _hideSnackbar();
          _setStateSafely();
        }).catchError(_showUnknownError);
      },
      child: ScrollConfiguration(
        behavior: NoOverScrollGlow(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Card(
            child: _getCardContent(),
          ),
        ),
      ),
    );
  }

  Widget _getCardContent() {
    final localization = AppLocalizations.of(context);
    if (!_isNfcEnabled) {
      return Align(
        alignment: Alignment(0, -0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              child: Text(localization.nfcSettingsButton),
              onPressed: () {
                _nfcHceService.openNfcSettings()
                    .then((_) => _setStateSafely())
                    .catchError(_showUnknownError);
              },
            ),
          ],
        ),
      );
    }
    return ListTile(
      title: Text(
        _isNfcServiceRunning ? localization.nfcServiceRunning : localization.nfcServiceStopped,
      ),
      trailing: Switch(
        value: _isNfcServiceRunning,
        onChanged: _isLoading ? null : (newValue) {
          _setStateSafely(cb: () {
            _isLoading = true;
          });
          final future = newValue ? _nfcHceService.startService() : _nfcHceService.stopService();
          future.catchError(_showUnknownError).whenComplete(() {
            _setStateSafely(cb: () {
              _isLoading = false;
            });
          });
        }
      ),
    );
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
    _snackbar.closed.whenComplete(() {
      _snackbar = null;
    });
  }

  void _hideSnackbar() {
    if (_snackbar != null) {
      _snackbar.close();
      _snackbar = null;
    }
  }
}