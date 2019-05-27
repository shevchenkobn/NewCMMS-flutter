import 'package:flutter/material.dart';
import 'package:newcmms_flutter/utils/common.dart';
import '../di.dart';
import '../services/nfc_hce.service.dart';
import '../localizations.dart';

class NfcHcePage extends StatefulWidget {
  static const routeName = 'nfc-hce/';
  static Future<dynamic> navigateTo(BuildContext context) => Navigator.pushNamed(context, routeName);
  static bool _navigateFrom(BuildContext context) => Navigator.pop(context);

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  AppBar _appBar;

  NfcHcePageState(this._nfcHceService)
      : _isNfcEnabled = null,
        _isNfcServiceRunning = null,
        _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loopRefresh();
  }

  @override
  Widget build(BuildContext context) {
    _appBar = AppBar(
      title: Text(AppLocalizations.of(context).nfcTitle),
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: _appBar,
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
    } else {
      return SizedBox(
        height: _getViewportHeight(),
        child: _getProgressBarDecoratedBody(),
      );
    }
  }

  Widget _getProgressBarDecoratedBody() {
    if (_isLoading) {
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
          child: SizedBox(
            height: _getViewportHeight(),
            child: _getCardContent(),
          ),
        ),
      ),
    );
  }

  Widget _getCardContent() {
    final localization = AppLocalizations.of(context);
    if (!_isNfcEnabled) {
      return Card(
        child: Align(
          alignment: Alignment(0, -0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(localization.nfcDisabledMessage),
              RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text(localization.nfcSettingsButton),
                onPressed: () {
                  _refreshAfter(_nfcHceService.openNfcSettings())
                      .whenComplete(() => _setStateSafely())
                      .catchError(_showUnknownError);
                },
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          child: ListTile(
            title: Text(
              _isNfcServiceRunning ? localization.nfcServiceRunning : localization.nfcServiceStopped,
            ),
            trailing: Switch(
              value: _isNfcServiceRunning,
              onChanged: _isLoading ? null : (newValue) {
                _setStateSafely(cb: () {
                  _isLoading = true;
                });
                _refreshAfter(newValue ? _nfcHceService.startService() : _nfcHceService.stopService())
                    .catchError(_showUnknownError).whenComplete(() {
                  _setStateSafely(cb: () {
                    _isLoading = false;
                  });
                });
              }
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshAfter(Future<dynamic> first) async {
    await first;
    await _refresh();
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
    _snackbar = _scaffoldKey.currentState.showSnackBar(
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

  double _getViewportHeight() {
    return MediaQuery.of(context).size.height - _appBar.preferredSize.height - 24;
  }
}