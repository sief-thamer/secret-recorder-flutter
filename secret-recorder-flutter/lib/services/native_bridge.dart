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
          final code = call.arguments['code'] as String;
          onDialCode?.call(code);
          break;
        case 'onOutgoingCall':
          final number = call.arguments['number'] as String;
          onOutgoingCall?.call(number);
          break;
        case 'onRecordingSaved':
          final filePath = call.arguments['filePath'] as String;
          final fileName = call.arguments['fileName'] as String;
          onRecordingSaved?.call(filePath, fileName);
          break;
      }
    });
  }

  static Future<void> startRecording() async {
    await _channel.invokeMethod('startRecording');
  }

  static Future<void> stopRecording() async {
    await _channel.invokeMethod('stopRecording');
  }

  static Future<String> getFilesDir() async {
    final result = await _channel.invokeMethod('getFilesDir');
    return result as String;
  }
}
