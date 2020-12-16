import 'dart:async';

import 'package:flutter/services.dart';

export 'package:pin_input_text_field/pin_input_text_field.dart';

class SmsAutoFill {
  static SmsAutoFill _singleton;
  static const MethodChannel _channel = const MethodChannel('sms_autofill');
  final StreamController<String> _code = StreamController.broadcast();

  factory SmsAutoFill() => _singleton ??= SmsAutoFill._();

  SmsAutoFill._() {
    _channel.setMethodCallHandler((method) {
      if (method.method == 'smscode') {
        _code.add(method.arguments);
      }
      return null;
    });
  }

  Stream<String> get code => _code.stream;

  Future<String> get hint async {
    final String version = await _channel.invokeMethod('requestPhoneHint');
    return version;
  }

  Future<void> get listenForCode async {
    await _channel.invokeMethod('listenForCode');
  }

  Future<void> unregisterListener() async {
    await _channel.invokeMethod('unregisterListener');
  }

  Future<String> get getAppSignature async {
    final String appSignature = await _channel.invokeMethod('getAppSignature');
    return appSignature;
  }
}

mixin CodeAutoFill {
  final SmsAutoFill _autoFill = SmsAutoFill();
  StreamSubscription _subscription;

  void listenForCode() {
    _subscription = _autoFill.code.listen((code) {
      codeUpdated(code);
    });
    _autoFill.listenForCode;
  }

  Future<void> unregisterListener() async {
    await _subscription?.cancel();
    return _autoFill.unregisterListener();
  }

  void codeUpdated(String code);
}
