import 'package:flutter/material.dart';
import 'package:newcmms_flutter/models/user.model.dart';
import 'package:newcmms_flutter/services/auth.service.dart';
import 'package:newcmms_flutter/services/http_client.service.dart';

import 'general_settings.page.dart';
import '../di.dart';
import '../localizations.dart';

class HomeDrawerContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ModuleContainer.getDefault().get<HomeDrawerContentState>();
  }
}

class HomeDrawerContentState extends State<HomeDrawerContent> {
  final HttpClient _httpClient;
  final AuthService _authService;

  HomeDrawerContentState(this._httpClient, this._authService);

  @override
  void initState() {
    super.initState();
    if (_authService.user != null || true) {
      _httpClient.refreshCurrentUser().then((user) {
        setState(() {});
      }).catchError((error, stackTrace) {
        print(error);
        print(stackTrace);
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations
                .of(context)
                .userLoadError)));
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountEmail: Text(_authService.user.email ?? localization.loading),
          accountName: Text(_authService.user.fullName ?? localization.loading),
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text(localization.userDrawerItem),
        ),
        ListTile(
          leading: Icon(Icons.nfc),
          title: Text(localization.checkInDrawerItem),
        ),
        ListTile(
          leading: Icon(Icons.playlist_add_check),
          title: Text(localization.triggerHistoryDrawerItem),
        ),
        ListTile(
          leading: Icon(Icons.perm_device_information),
          title: Text(localization.triggerDevicesDrawerItem),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text(localization.settingsDrawerItem),
          onTap: () {
            GeneralSettingsPage.navigateTo(context);
          },
        )
      ],
    );
  }
}