import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/native_bridge.dart';
import 'dart:io';

class RecorderProvider extends ChangeNotifier {
  bool _isRecordingAudio = false;
  bool _isRecordingVideo = false;
  String _lastSavedFile = '';
  List<RecordedFile> _recordings = [];

  bool get isRecordingAudio => _isRecordingAudio;
  bool get isRecordingVideo => _isRecordingVideo;
  String get lastSavedFile => _lastSavedFile;
  List<RecordedFile> get recordings => _recordings;

  RecorderProvider() { _loadRecordings(); _setupCallbacks(); }

  void _setupCallbacks() {
    NativeBridge.onDialCode = (code) => handleDialCode(code);
    NativeBridge.onOutgoingCall = (number) => handleDialCode(number);
    NativeBridge.onRecordingSaved = (filePath, fileName) => _saveRecordingRecord(filePath, fileName);
  }

  void handleDialCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final audioStart = prefs.getString('audio_start_code') ?? '*#0#*';
    final audioStop = prefs.getString('audio_stop_code') ?? '#*25#*';
    final videoStart = prefs.getString('video_start_code') ?? '*#00#*';
    final videoStop = prefs.getString('video_stop_code') ?? '#*26#*';
    if (code == audioStart) startAudioRecording();
    else if (code == audioStop) stopAudioRecording();
    else if (code == videoStart) startVideoRecording();
    else if (code == videoStop) stopVideoRecording();
  }

  Future<void> startAudioRecording() async { if (_isRecordingAudio) return; await NativeBridge.startRecording(); _isRecordingAudio = true; notifyListeners(); }
  Future<void> stopAudioRecording() async { if (!_isRecordingAudio) return; await NativeBridge.stopRecording(); _isRecordingAudio = false; notifyListeners(); }
  Future<void> startVideoRecording() async { if (_isRecordingVideo) return; _isRecordingVideo = true; notifyListeners(); }
  Future<void> stopVideoRecording() async { if (!_isRecordingVideo) return; _isRecordingVideo = false; notifyListeners(); }
  void stopAll() { stopAudioRecording(); stopVideoRecording(); }

  Future<void> _saveRecordingRecord(String filePath, String fileName) async {
    final file = File(filePath);
    final fileSize = await file.length();
    _recordings.insert(0, RecordedFile(id: DateTime.now().millisecondsSinceEpoch, fileName: fileName, filePath: filePath, fileSize: fileSize, isAudio: true, createdAt: DateTime.now()));
    _lastSavedFile = filePath;
    notifyListeners();
    await _saveRecordingsToPrefs();
  }

  Future<void> _loadRecordings() async { final prefs = await SharedPreferences.getInstance(); final list = prefs.getStringList('recordings') ?? []; _recordings = list.map((s) => RecordedFile.fromString(s)).toList(); notifyListeners(); }
  Future<void> _saveRecordingsToPrefs() async { final prefs = await SharedPreferences.getInstance(); await prefs.setStringList('recordings', _recordings.map((r) => r.toString()).toList()); }
  Future<void> deleteRecording(RecordedFile r) async { final f = File(r.filePath); if (await f.exists()) await f.delete(); _recordings.removeWhere((x) => x.id == r.id); notifyListeners(); await _saveRecordingsToPrefs(); }
}

class RecordedFile {
  final int id; final String fileName; final String filePath; final int fileSize; final bool isAudio; final bool isVideo; final DateTime createdAt;
  RecordedFile({required this.id, required this.fileName, required this.filePath, required this.fileSize, this.isAudio = true, this.isVideo = false, required this.createdAt});
  String get formattedSize { if (fileSize < 1024) return '$fileSize B'; if (fileSize < 1048576) return '${(fileSize / 1024).toStringAsFixed(1)} KB'; return '${(fileSize / 1048576).toStringAsFixed(1)} MB'; }
  @override String toString() => '$id|$fileName|$filePath|$fileSize|$isAudio|$isVideo|${createdAt.toIso8601String()}';
  factory RecordedFile.fromString(String s) { final p = s.split('|'); return RecordedFile(id: int.parse(p[0]), fileName: p[1], filePath: p[2], fileSize: int.parse(p[3]), isAudio: p[4] == 'true', isVideo: p[5] == 'true', createdAt: DateTime.parse(p[6])); }
}