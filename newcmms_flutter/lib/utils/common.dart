import 'package:flutter/services.dart';

Future<void> exitGracefully() {
  return SystemNavigator.pop();
}

typedef void ReturnCallback();
