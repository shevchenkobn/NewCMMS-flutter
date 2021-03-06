import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) async {
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

  String get dialogYes => Intl.message('Yes', name: 'dialogYes');

  String get dialogNo => Intl.message('No', name: 'dialogNo');

  String get unknownError => Intl.message('Unknown error. Try again later.', name: 'unknownError');

  String get internetError => Intl.message('Unable to connect to server. Check Internet connection and server accessibility.', name: 'internetError');

  String get ok => Intl.message('OK', name: 'ok');

  String get nothingFound => Intl.message('Nothing found.', name: 'nothingFound');

  String get userPageTitle {
    return Intl.message('NewCMMS App User', name: 'userPageTitle');
  }

  String get userDrawerItem => Intl.message('Account', name: 'userDrawerItem');

  String get userLoadError => Intl.message('Failed to load user', name: 'userLoadError');

  String get triggerHistoryDrawerItem => Intl.message('Trigger history', name: 'triggerHistoryDrawerItem');

  String get triggerDevicesDrawerItem => Intl.message('Trigger devices', name: 'triggerDevicesDrawerItem');

  String get checkInDrawerItem => Intl.message('NFC check-in', name: 'checkInDrawerItem');

  String get settingsDrawerItem => Intl.message('Settings', name: 'settingsDrawerItem');

  String get settingsPageTitle => Intl.message('Settings', name: 'settingsPageTitle');

  String get settingsPageBaseUrlLabel => Intl.message('Server URL', name: 'settingsPageBaseUrlLabel');

  String get settingsPageInvalidBaseUrlError => Intl.message('A valid URL is required', name: 'settingsPageInvalidBaseUrlError');

  String get settingsPageLogoutLabel => Intl.message('Log out', name: 'settingsPageLogoutLabel');

  String get settingsPageLogoutPrompt => Intl.message('Are you sure you want to log out?', name: 'settingsPageLogoutPrompt');

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

  String get userEmail => Intl.message('Email', name: 'userEmail');

  String get userFullName => Intl.message('Full name', name: 'userFullName');

  String get userRoleEmployee => Intl.message('Employee', name: 'userRoleEmployee');

  String get userRoleAdmin => Intl.message('Admin', name: 'userRoleAdmin');

  String get triggerDevicesPageTitle => Intl.message('Trigger devices', name: 'triggerDevicesPageTitle');

  String get triggerDevicePageTitle => Intl.message('Trigger device details', name: 'triggerDevicePageTitle');

  String get triggerDevicePhysicalAddress => Intl.message('Physical address', name: 'triggerDevicePhysicalAddress');

  String get triggerDeviceName => Intl.message('Device name', name: 'triggerDeviceName');

  String get triggerDeviceType => Intl.message('Device type', name: 'triggerDeviceType');

  String get triggerDeviceStatusConnected => Intl.message('Connected', name: 'triggerDeviceStatusConnected');

  String get triggerDeviceStatusDisconnected => Intl.message('Disconnected', name: 'triggerDeviceStatusDisconnected');

  String get userTriggersPageTitle => Intl.message('Trigger history', name: 'userTriggersPageTitle');
  
  String get userTriggerTriggerDeviceName => Intl.message('Trigger device name', name: 'userTriggerTriggerDeviceName');

  String get userTriggerTriggerDeviceNameUnknown => Intl.message('Unknown', name: 'userTriggerTriggerDeviceNameUnknown');
  
  String get userTriggerTypeUnspecified => Intl.message('Unspecified', name: 'userTriggerTypeUnspecified');

  String get userTriggerTypeEnter => Intl.message('Entered', name: 'userTriggerTypeEnter');

  String get userTriggerTypeLeft => Intl.message('Left', name: 'userTriggerTypeLeft');

  String get nfcTitle => Intl.message('NFC check-in', name: 'nfcTitle');

  String get nfcDisabledMessage => Intl.message('NFC is disabled', name: 'nfcDisabledMessage');

  String get nfcSettingsButton => Intl.message('Open NFC settings', name: 'nfcSettingsButton');

  String get nfcServiceRunning => Intl.message('Up and running', name: 'nfcServiceRunning');

  String get nfcServiceStopped => Intl.message('Stopped', name: 'nfcServiceStopped');
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
