import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _audioStartController;
  late TextEditingController _audioStopController;
  late TextEditingController _videoStartController;
  late TextEditingController _videoStopController;
  late bool _useVibrate;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _audioStartController = TextEditingController(text: settings.audioStartCode);
    _audioStopController = TextEditingController(text: settings.audioStopCode);
    _videoStartController = TextEditingController(text: settings.videoStartCode);
    _videoStopController = TextEditingController(text: settings.videoStopCode);
    _useVibrate = settings.useVibrate;
  }

  @override
  void dispose() {
    _audioStartController.dispose();
    _audioStopController.dispose();
    _videoStartController.dispose();
    _videoStopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Audio Codes Section
            _buildSectionTitle('Audio Codes', Colors.green),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _audioStartController,
              label: 'Audio Start Code',
              hint: '*#0#*',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _audioStopController,
              label: 'Audio Stop Code',
              hint: '#*25#*',
              color: Colors.green,
            ),
            
            const SizedBox(height: 24),
            
            // Video Codes Section
            _buildSectionTitle('Video Codes', Colors.blue),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _videoStartController,
              label: 'Video Start Code',
              hint: '*#00#*',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _videoStopController,
              label: 'Video Stop Code',
              hint: '#*26#*',
              color: Colors.blue,
            ),
            
            const SizedBox(height: 24),
            
            // Options Section
            _buildSectionTitle('Options', Colors.orange),
            const SizedBox(height: 12),
            
            SwitchListTile(
              title: const Text('Vibrate on code activation'),
              subtitle: const Text('Vibrate when secret code is entered'),
              value: _useVibrate,
              onChanged: (value) {
                setState(() {
                  _useVibrate = value;
                });
              },
              activeColor: Colors.green,
            ),
            
            const SizedBox(height: 30),
            
            // Save Button
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(fontSize: 16),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to use:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Dial the secret code on your phone\n'
                      '2. Recording will start automatically\n'
                      '3. Dial the stop code to stop recording\n'
                      '4. Files are encrypted and saved securely',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color),
        ),
        labelStyle: TextStyle(color: color),
      ),
      style: const TextStyle(fontFamily: 'monospace'),
    );
  }

  void _saveSettings() async {
    final settings = context.read<SettingsProvider>();
    
    final audioStart = _audioStartController.text.trim();
    final audioStop = _audioStopController.text.trim();
    final videoStart = _videoStartController.text.trim();
    final videoStop = _videoStopController.text.trim();
    
    if (audioStart.isEmpty || audioStop.isEmpty || videoStart.isEmpty || videoStop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (audioStart == audioStop || videoStart == videoStop) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start and stop codes must be different'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    await settings.updateSettings(
      audioStartCode: audioStart,
      audioStopCode: audioStop,
      videoStartCode: videoStart,
      videoStopCode: videoStop,
      useVibrate: _useVibrate,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
