import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

enum RegistrationReply { none, newRegistration, failed, refused, timeout }

class UnifiedPush {
  static MethodChannel _channel = MethodChannel(PLUGIN_CHANNEL);
  static final _msg = <String>[];
  static void Function(String endpoint) _onNewEndpoint = (String _) {};
  static void Function() _onRegistrationRefused = () {};
  static void Function() _onRegistrationFailed = () {};
  static void Function() _onUnregistered = () {};
  static void Function(String message) _onMessage = (String _) {};

  static Future<void> setListeners({
    void Function(String endpoint) onNewEndpoint,
    void Function() onRegistrationFailed,
    void Function() onRegistrationRefused,
    void Function() onUnregistered,
    void Function(String message) onMessage,
  }) async {
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onRegistrationRefused = onRegistrationRefused;
    _onUnregistered = onUnregistered;
    _onMessage = onMessage;

    if (_onMessage != null) {
      _msg.forEach(_onMessage);
      _msg.clear();
    }

    _channel.setMethodCallHandler(onMethodCall);
  }

  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.method);
    switch (call.method) {
      case "onNewEndpoint":
        _onNewEndpoint?.call(call.arguments);
        break;
      case "onRegistrationRefused":
        _onRegistrationRefused?.call();
        break;
      case "onRegistrationFailed":
        _onRegistrationFailed?.call();
        break;
      case "onUnregistered":
        _onUnregistered?.call();
        break;
      case "onMessage":
        if (_onMessage != null) {
          _onMessage(call.arguments);
        } else {
          _msg.add(call.arguments);
        }
        break;
    }
  }

  static Future<void> unregister() async {
    await _channel.invokeMethod(PLUGIN_EVENT_UNREGISTER);
  }

  static Future<void> registerAppWithDialog() async {
    await _channel.invokeMethod(PLUGIN_EVENT_REGISTER_APP_WITH_DIALOG);
  }

  static Future<List<String>> getDistributors() async {
    return (await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTORS))
        .cast<String>();
  }

  static Future<void> saveDistributor(String distributor) async {
    await _channel.invokeMethod(PLUGIN_EVENT_SAVE_DISTRIBUTOR, distributor);
  }

  static Future<void> registerApp() async {
    await _channel.invokeMethod(PLUGIN_EVENT_REGISTER_APP);
  }
}
