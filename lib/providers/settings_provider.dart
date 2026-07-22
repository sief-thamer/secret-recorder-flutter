import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
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

  SettingsProvider() { _loadSettings(); }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _audioStartCode = prefs.getString('audio_start_code') ?? '*#0#*';
    _audioStopCode = prefs.getString('audio_stop_code') ?? '#*25#*';
    _videoStartCode = prefs.getString('video_start_code') ?? '*#00#*';
    _videoStopCode = prefs.getString('video_stop_code') ?? '#*26#*';
    _useVibrate = prefs.getBool('use_vibrate') ?? true;
  }

  Future<void> updateSettings({String? audioStartCode, String? audioStopCode, String? videoStartCode, String? videoStopCode, bool? useVibrate}) async {
    final prefs = await SharedPreferences.getInstance();
    if (audioStartCode != null) { _audioStartCode = audioStartCode; await prefs.setString('audio_start_code', audioStartCode); }
    if (audioStopCode != null) { _audioStopCode = audioStopCode; await prefs.setString('audio_stop_code', audioStopCode); }
    if (videoStartCode != null) { _videoStartCode = videoStartCode; await prefs.setString('video_start_code', videoStartCode); }
    if (videoStopCode != null) { _videoStopCode = videoStopCode; await prefs.setString('video_stop_code', videoStopCode); }
    if (useVibrate != null) { _useVibrate = useVibrate; await prefs.setBool('use_vibrate', useVibrate); }
  }
}