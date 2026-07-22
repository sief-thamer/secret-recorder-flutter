import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
  static const _audioStartKey = 'audio_start_code';
  static const _audioStopKey = 'audio_stop_code';
  static const _videoStartKey = 'video_start_code';
  static const _videoStopKey = 'video_stop_code';
  static const _useVibrateKey = 'use_vibrate';

  String _audioStartCode = '*#0#*';
  String _audioStopCode = '#*25#*';
  String _videoStartCode = '*#00#*';
  String _videoStopCode = '#*26#*';
  bool _useVibrate = true;

  String get audioStartCode => _audioStartCode;
  String get audioStopCode => _audioStopCode;
  String get videoStartCode => _videoStartCode;
  String get videoStopCode => _videoStopCode;
  bool get useVibrate => _useVibrate;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _audioStartCode = prefs.getString(_audioStartKey) ?? '*#0#*';
    _audioStopCode = prefs.getString(_audioStopKey) ?? '#*25#*';
    _videoStartCode = prefs.getString(_videoStartKey) ?? '*#00#*';
    _videoStopCode = prefs.getString(_videoStopKey) ?? '#*26#*';
    _useVibrate = prefs.getBool(_useVibrateKey) ?? true;
  }

  Future<void> updateSettings({
    String? audioStartCode,
    String? audioStopCode,
    String? videoStartCode,
    String? videoStopCode,
    bool? useVibrate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (audioStartCode != null) {
      _audioStartCode = audioStartCode;
      await prefs.setString(_audioStartKey, audioStartCode);
    }
    if (audioStopCode != null) {
      _audioStopCode = audioStopCode;
      await prefs.setString(_audioStopKey, audioStopCode);
    }
    if (videoStartCode != null) {
      _videoStartCode = videoStartCode;
      await prefs.setString(_videoStartKey, videoStartCode);
    }
    if (videoStopCode != null) {
      _videoStopCode = videoStopCode;
      await prefs.setString(_videoStopKey, videoStopCode);
    }
    if (useVibrate != null) {
      _useVibrate = useVibrate;
      await prefs.setBool(_useVibrateKey, useVibrate);
    }
  }
}
