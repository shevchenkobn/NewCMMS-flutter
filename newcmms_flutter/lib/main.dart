import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:newcmms_flutter/di.dart';

import 'localizations.dart';
import 'widgets/general_settings.page.dart';
import 'widgets/home.page.dart';
import 'widgets/login.dart';
import 'widgets/nfc_hce.page.dart';
import 'widgets/trigger_device.dart';

void main() {
  ModuleContainer().initializeDefault().then(
      (_) => runApp(MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      onGenerateTitle: (BuildContext context) =>
        AppLocalizations.of(context).title,
      supportedLocales: [
        const Locale('en'),
        const Locale('uk'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        HomePage.routeName: (context) => HomePage(),
        GeneralSettingsPage.routeName: (context) => GeneralSettingsPage(),
        TriggerDevicePage.routeName: (context) => TriggerDevicePage(),
        NfcHcePage.routeName: (context) => NfcHcePage(),
      },
    );
  }
}
