import 'package:flutter/material.dart';

import 'general_settings.page.dart';
import '../di.dart';
import '../localizations.dart';

class LoginDrawerContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ModuleContainer.getDefault().get<LoginDrawerContentState>();
}

class LoginDrawerContentState extends State<LoginDrawerContent> {
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text(localization.loginPageTitle),
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