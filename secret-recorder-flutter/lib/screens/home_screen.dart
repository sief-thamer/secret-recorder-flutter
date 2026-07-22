import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recorder_provider.dart';
import '../providers/settings_provider.dart';
import '../services/native_bridge.dart';
import 'settings_screen.dart';
import 'recordings_screen.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _setupDialCodeListener();
  }

  void _setupDialCodeListener() {
    NativeBridge.onDialCode = (code) {
      final settings = context.read<SettingsProvider>();
      final recorder = context.read<RecorderProvider>();
      recorder.handleDialCode(code);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code received: $code'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secret Recorder'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<RecorderProvider>(
        builder: (context, recorder, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Audio Section
                _buildSectionTitle('Audio Recording', Colors.green),
                const SizedBox(height: 12),
                _buildRecordingButtons(
                  context: context,
                  isRecording: recorder.isRecordingAudio,
                  onStart: () => recorder.startAudioRecording(),
                  onStop: () => recorder.stopAudioRecording(),
                  startColor: Colors.green,
                  label: 'Audio',
                ),
                
                const SizedBox(height: 30),
                
                // Video Section
                _buildSectionTitle('Video Recording', Colors.blue),
                const SizedBox(height: 12),
                _buildRecordingButtons(
                  context: context,
                  isRecording: recorder.isRecordingVideo,
                  onStart: () => recorder.startVideoRecording(),
                  onStop: () => recorder.stopVideoRecording(),
                  startColor: Colors.blue,
                  label: 'Video',
                ),
                
                const SizedBox(height: 30),
                
                // Stop All
                ElevatedButton(
                  onPressed: recorder.isRecordingAudio || recorder.isRecordingVideo
                      ? () => recorder.stopAll()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Stop All Recording',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Divider
                const Divider(color: Colors.grey),
                const SizedBox(height: 20),
                
                // Secret Codes Info
                _buildSecretCodesInfo(context),
                
                const SizedBox(height: 30),
                
                // Recordings Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecordingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.folder),
                  label: const Text('View Recordings'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRecordingButtons({
    required BuildContext context,
    required bool isRecording,
    required VoidCallback onStart,
    required VoidCallback onStop,
    required Color startColor,
    required String label,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isRecording ? null : onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: startColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Start $label', style: const TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isRecording ? onStop : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Stop $label', style: const TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildSecretCodesInfo(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secret Codes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCodeRow('Audio Start', settings.audioStartCode, Colors.green),
            _buildCodeRow('Audio Stop', settings.audioStopCode, Colors.red),
            _buildCodeRow('Video Start', settings.videoStartCode, Colors.blue),
            _buildCodeRow('Video Stop', settings.videoStopCode, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeRow(String label, String code, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            code,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
