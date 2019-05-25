import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
    locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get title {
    return Intl.message('NewCMMS App',
        name: 'title', desc: 'The application title');
  }

  String get loading => Intl.message('Loading...', name: 'loading');

  String get unknownError => Intl.message('Unknown error. Try again later.', name: 'unknownError');

  String get internetError => Intl.message('Unable to connect to server. Check Internet connection and server accessibility.', name: 'internetError');

  String get ok => Intl.message('OK', name: 'ok');

  String get userPageTitle {
    return Intl.message('NewCMMS App User', name: 'userPageTitle');
  }

  String get userDrawerItem => Intl.message('Account info', name: 'userDrawerItem');

  String get userLoadError => Intl.message('Failed to load user', name: 'userDrawerUserError');

  String get triggerHistoryDrawerItem => Intl.message('Trigger history', name: 'triggerHistoryDrawerItem');

  String get triggerDevicesDrawerItem => Intl.message('Trigger devices', name: 'triggerDevicesDrawerItem');

  String get checkInDrawerItem => Intl.message('Check-in', name: 'checkInDrawerItem');

  String get settingsDrawerItem => Intl.message('Settings', name: 'settingsDrawerItem');

  String get settingsPageTitle => Intl.message('Settings', name: 'settingsPageTitle');

  String get settingsPageBaseUrlLabel => Intl.message('Server URL', name: 'settingsPageBaseUrlLabel');

  String get settingsPageInvalidBaseUrlError => Intl.message('A valid URL is required', name: 'settingsPageInvalidBaseUrlError');

  String get loginPageTitle {
    return Intl.message('NewCMMS Login', name: 'loginPageTitle');
  }

  String get loginPageLoginLabel {
    return Intl.message('Login', name: 'loginPageLoginLabel');
  }

  String get loginPagePasswordLabel {
    return Intl.message('Password', name: 'loginPagePasswordLabel');
  }

  String get loginPageSubmitLabel {
    return Intl.message('Log in', name: 'loginPageSubmitLabel');
  }

  String get loginPageEmailError {
    return Intl.message('Invalid email', name: 'loginPageEmailError');
  }

  String get loginPagePasswordError {
    return Intl.message('Password is required', name: 'loginPagePasswordError');
  }

  String get loginPageLoginOrPasswordError {
    return Intl.message('Invalid login or password', name: 'loginPageLoginOrPasswordError');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  static const List<String> localeLanguageCodes = const ['en', 'uk'];
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return localeLanguageCodes.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
