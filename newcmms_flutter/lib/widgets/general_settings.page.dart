import 'package:flutter/material.dart';
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

  GeneralSettingsPageState(this._httpClient);
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
    final list = [
      Positioned(
          top: 0,
          child: Column(
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
                  _httpClient.setBaseUrl(_baseApiController.text).then((_) {
                    setState(() {
                      _baseApiInvalid = false;
                    });
                    GeneralSettingsPage._navigateFrom(context);
                  }).catchError((error) {
                    if (error is ArgumentError) {
                      setState(() {
                        _baseApiInvalid = true;
                      });
                    } else {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localization.unknownError),
                          duration: Duration(days: 10),
                        ),
                      );
                    }
                  }).whenComplete(() => setState(() {
                    _isSaving = false;
                  }));
                },
              ),
            ],
          )
      ),
    ];
    if (_isSaving) {
      list.add(Positioned(
        top: 0,
        child: LinearProgressIndicator(
          value: null,
        ),
      ));
    }
    return list;
  }
}