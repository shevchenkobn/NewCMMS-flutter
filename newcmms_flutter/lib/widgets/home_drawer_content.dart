import 'package:flutter/material.dart';
import 'package:newcmms_flutter/models/user.model.dart';
import 'package:newcmms_flutter/services/auth.service.dart';
import 'package:newcmms_flutter/services/http_client.service.dart';

import 'general_settings.page.dart';
import '../di.dart';
import '../localizations.dart';
import 'home.page.dart';

class HomeDrawerContent extends StatefulWidget {
  final OnItemTapCallback _onItemTap;

  HomeDrawerContent({@required OnItemTapCallback onItemTap})
    : assert(onItemTap != null), _onItemTap = onItemTap;

  @override
  State<StatefulWidget> createState() {
    return ModuleContainer.getDefault().get<HomeDrawerContentState>(additionalParameters: {
      HomeDrawerContentState.onItemTapParamName: _onItemTap,
    });
  }
}

typedef void OnItemTapCallback(PageContentType contentType);

class HomeDrawerContentState extends State<HomeDrawerContent> {
  static const onItemTapParamName = 'onItemTap';

  final HttpClient _httpClient;
  final AuthService _authService;
  final OnItemTapCallback _onItemTap;

  HomeDrawerContentState(this._httpClient, this._authService, OnItemTapCallback onItemTap)
    : assert(onItemTap != null), _onItemTap = onItemTap;

  @override
  void initState() {
    super.initState();
    if (_authService.user == null) {
      _httpClient.refreshCurrentUser().then((user) {
        _setStateSafely();
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
          onDetailsPressed: () {
            _safeOnItemTap(PageContentType.user);
          },
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text(localization.userDrawerItem),
          onTap: () {
            _safeOnItemTap(PageContentType.user);
          },
        ),
        ListTile(
          leading: Icon(Icons.nfc),
          title: Text(localization.checkInDrawerItem),
          onTap: () {
//            _safeOnItemTap(PageContentType.user);
          },
        ),
        ListTile(
          leading: Icon(Icons.playlist_add_check),
          title: Text(localization.triggerHistoryDrawerItem),
          onTap: () {
            _safeOnItemTap(PageContentType.triggerHistory);
          },
        ),
        ListTile(
          leading: Icon(Icons.perm_device_information),
          title: Text(localization.triggerDevicesDrawerItem),
          onTap: () {
            _safeOnItemTap(PageContentType.triggers);
          },
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

  void _safeOnItemTap(PageContentType contentType) {
    try {
      _onItemTap(contentType);
    } catch (error, stackTrace) {
      print('Error while Drawer tap');
      print(error);
      print(stackTrace);
    }
  }

  void _setStateSafely({VoidCallback cb}) {
    if (mounted) {
      setState(cb ?? () {});
    }
  }
}