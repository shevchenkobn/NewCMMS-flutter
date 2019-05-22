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

  String get loginPageLoginLabel {
    return Intl.message('Login', name: 'loginPageLoginLabel');
  }

  String get loginPagePasswordLabel {
    return Intl.message('Password', name: 'loginPagePasswordLabel');
  }

  String get loginPageSubmitLabel {
    return Intl.message('Log in', name: 'loginPageSubmitLabel');
  }

  String get loginPagePasswordIsRequiredError {
    return Intl.message('Password is required', name: 'loginPagePasswordIsRequiredError');
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
