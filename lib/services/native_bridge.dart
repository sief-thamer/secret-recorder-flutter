import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.secretrecorder/native');
  static Function(String)? onDialCode;
  static Function(String)? onOutgoingCall;
  static Function(String, String)? onRecordingSaved;

  static Future<void> init() async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onDialCode':
          onDialCode?.call(call.arguments['code'] as String);
          break;
        case 'onOutgoingCall':
          onOutgoingCall?.call(call.arguments['number'] as String);
          break;
        case 'onRecordingSaved':
          onRecordingSaved?.call(call.arguments['filePath'] as String, call.arguments['fileName'] as String);
          break;
      }
    });
  }

  static Future<void> startRecording() async => await _channel.invokeMethod('startRecording');
  static Future<void> stopRecording() async => await _channel.invokeMethod('stopRecording');
  static Future<String> getFilesDir() async => await _channel.invokeMethod('getFilesDir') as String;
}