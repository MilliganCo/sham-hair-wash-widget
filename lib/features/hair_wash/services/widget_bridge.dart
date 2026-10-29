import 'package:flutter/services.dart';

class WidgetBridge {
  static const MethodChannel _channel = MethodChannel('com.codex.sham/widget');

  Future<void> refreshWidget() async {
    try {
      await _channel.invokeMethod<void>('refreshWidget');
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  Future<bool> requestPinWidget() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPinWidget');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
