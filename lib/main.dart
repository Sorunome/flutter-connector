import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Constants.dart';
import 'CallbackDispatcher.dart';

const PREF_ON_NEW_ENDPOINT = "unifiedpush/method:onNewEnpoint";
const PREF_ON_REGISTRATION_REFUSED = "unifiedpush/method:onRegistrationRefused";
const PREF_ON_REGISTRATION_FAILED = "unifiedpush/method:onRegistrationFailed";
const PREF_ON_UNREGISTERED = "unifiedpush/method:onUnregistered";
const PREF_ON_MESSAGE = "unifiedpush/method:onMessage";

enum RegistrationReply { none, newRegistration, failed, refused, timeout }

class UnifiedPush {
  static MethodChannel _channel = MethodChannel(PLUGIN_CHANNEL);

  static SharedPreferences prefs;

  static void Function(String endpoint) _onNewEndpoint = (String _) {};
  static void Function() _onRegistrationRefused = () {};
  static void Function() _onRegistrationFailed = () {};
  static void Function() _onUnregistered = () {};
  static void Function(String message) _onMessage = (String _) {};

  static Future<void> initialize(
      void Function(String endpoint) onNewEndpoint,
      void Function() onRegistrationFailed,
      void Function() onRegistrationRefused,
      void Function() onUnregistered,
      void Function(String message) onMessage,
      void Function(String endpoint) bgNewEndpoint,
      void Function() bgUnregistered,
      void Function(String message) bgMessage
      ) async {

    prefs = await SharedPreferences.getInstance();

    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onRegistrationRefused = onRegistrationRefused;
    _onUnregistered = onUnregistered;
    _onMessage = onMessage;

    _channel.setMethodCallHandler(onMethodCall);

    prefs.setInt(
        PREF_ON_NEW_ENDPOINT,
        PluginUtilities.getCallbackHandle(bgNewEndpoint)?.toRawHandle()
    );
    prefs.setInt(
        PREF_ON_UNREGISTERED,
        PluginUtilities.getCallbackHandle(bgUnregistered)?.toRawHandle()
    );
    prefs.setInt(
        PREF_ON_MESSAGE,
        PluginUtilities.getCallbackHandle(bgMessage)?.toRawHandle()
    );

    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);

    await _channel.invokeMethod(
        PLUGIN_EVENT_INITIALIZE_CALLBACK,
        <dynamic>[callback.toRawHandle()]
    );
    debugPrint("initialization finished");
  }

  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.method);
    switch (call.method) {
      case "onNewEndpoint":
        _onNewEndpoint(call.arguments);
        break;
      case "onRegistrationRefused":
        _onRegistrationRefused();
        break;
      case "onRegistrationFailed":
        _onRegistrationFailed();
        break;
      case "onUnregistered":
        _onUnregistered();
        break;
      case "onMessage":
        _onMessage(call.arguments);
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
    return await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTORS);
  }

  static Future<void> saveDistributor(String distributor) async {
    await _channel.invokeMethod(PLUGIN_EVENT_SAVE_DISTRIBUTOR, distributor);
  }

  static Future<void> registerApp() async {
    await _channel.invokeMethod(PLUGIN_EVENT_REGISTER_APP);
  }
}
