import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newcmms_flutter/services/http_client.service.dart';

import '../di.dart';
import '../localizations.dart';

class GeneralSettingsPage extends StatefulWidget {
  static String routeName = '/settings';
  static void navigateTo(BuildContext context) => Navigator.pushNamed(context, routeName);
  static void _navigateFrom(BuildContext context) => Navigator.pop(context);

  @override
  State<StatefulWidget> createState() => ModuleContainer.getDefault().get<GeneralSettingsPageState>();
}

class GeneralSettingsPageState extends State<GeneralSettingsPage> {
  final HttpClient _httpClient;
  final TextEditingController _baseApiController = TextEditingController();
  bool _baseApiInvalid = false;
  bool _isSaving = false;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snackbar;

  GeneralSettingsPageState(this._httpClient);

  @override
  void initState() {
    super.initState();
    if (!_baseApiInvalid) {
      _baseApiController.text = _httpClient.baseUrl;
    }
  }
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async => !_isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localization.settingsPageTitle),
        ),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: _getStackList(),
        ),
      ),
    );
  }

  List<Widget> _getStackList() {
    final localization = AppLocalizations.of(context);
    final list = <Widget>[
      Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _baseApiController,
                decoration: InputDecoration(
                  labelText: localization.settingsPageBaseUrlLabel,
                  errorText: _baseApiInvalid ? localization.settingsPageInvalidBaseUrlError : null,
                ),
                onEditingComplete: () {
                  setState(() {
                    _baseApiInvalid = true;
                  });
                  _httpClient.setBaseUrl(_baseApiController.text).whenComplete(() => setState(() {
                    setState(() {
                      _isSaving = false;
                    });
                    _hideSnackbar();
                  })).then((_) {
                    setState(() {
                      _baseApiInvalid = false;
                    });
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  }).catchError((error) {
                    if (error is ArgumentError) {
                      setState(() {
                        _baseApiInvalid = true;
                      });
                    } else {
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
                  });
                },
              ),
            ],
          ),
        ),
      ),
    ];
    if (_isSaving) {
      list.add(Align(
        alignment: AlignmentDirectional.topCenter,
        child: LinearProgressIndicator(
          value: null,
        )
      ));
    }
    return list;
  }

  @override
  void dispose() {
    _baseApiController.dispose();
    super.dispose();
  }

  void _hideSnackbar() {
    if (_snackbar != null) {
      _snackbar.close();
      _snackbar = null;
    }
  }
}