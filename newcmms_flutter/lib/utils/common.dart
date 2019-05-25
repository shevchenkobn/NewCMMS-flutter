import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Future<void> exitGracefully() {
  return SystemNavigator.pop();
}

typedef void ReturnCallback();

class NoOverScrollGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
