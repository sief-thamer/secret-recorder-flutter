import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recorder_provider.dart';
import '../providers/settings_provider.dart';
import '../services/native_bridge.dart';
import 'settings_screen.dart';
import 'recordings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    NativeBridge.onDialCode = (code) {
      context.read<RecorderProvider>().handleDialCode(code);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Code: $code'), backgroundColor: Colors.green, duration: Duration(seconds: 1)));
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secret Recorder'), centerTitle: true, actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())))]),
      body: Consumer<RecorderProvider>(builder: (context, r, _) => SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 20),
        const Text('Audio Recording', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton(onPressed: r.isRecordingAudio ? null : () => r.startAudioRecording(), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Start Audio'))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: r.isRecordingAudio ? () => r.stopAudioRecording() : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Stop Audio'))),
        ]),
        const SizedBox(height: 30),
        const Text('Video Recording', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton(onPressed: r.isRecordingVideo ? null : () => r.startVideoRecording(), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Start Video'))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: r.isRecordingVideo ? () => r.stopVideoRecording() : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Stop Video'))),
        ]),
        const SizedBox(height: 30),
        ElevatedButton(onPressed: r.isRecordingAudio || r.isRecordingVideo ? () => r.stopAll() : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Stop All Recording')),
        const SizedBox(height: 30),
        const Divider(color: Colors.grey),
        const SizedBox(height: 20),
        _buildCodesInfo(context),
        const SizedBox(height: 30),
        ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordingsScreen())), icon: const Icon(Icons.folder), label: const Text('View Recordings'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16))),
      ]))));
  }

  Widget _buildCodesInfo(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Secret Codes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _row('Audio Start', s.audioStartCode, Colors.green),
      _row('Audio Stop', s.audioStopCode, Colors.red),
      _row('Video Start', s.videoStartCode, Colors.blue),
      _row('Video Stop', s.videoStopCode, Colors.red),
    ])));
  }

  Widget _row(String label, String code, Color c) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(code, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontFamily: 'monospace'))]));
}