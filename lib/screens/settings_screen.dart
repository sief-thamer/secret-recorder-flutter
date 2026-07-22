import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _as, _as2, _vs, _vs2;
  late bool _vib;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>();
    _as = TextEditingController(text: s.audioStartCode);
    _as2 = TextEditingController(text: s.audioStopCode);
    _vs = TextEditingController(text: s.videoStartCode);
    _vs2 = TextEditingController(text: s.videoStopCode);
    _vib = s.useVibrate;
  }

  @override
  void dispose() { _as.dispose(); _as2.dispose(); _vs.dispose(); _vs2.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Audio Codes', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _tf(_as, 'Audio Start Code', '*#0#*', Colors.green),
        const SizedBox(height: 12),
        _tf(_as2, 'Audio Stop Code', '#*25#*', Colors.green),
        const SizedBox(height: 24),
        const Text('Video Codes', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _tf(_vs, 'Video Start Code', '*#00#*', Colors.blue),
        const SizedBox(height: 12),
        _tf(_vs2, 'Video Stop Code', '#*26#*', Colors.blue),
        const SizedBox(height: 24),
        SwitchListTile(title: const Text('Vibrate on code activation'), value: _vib, onChanged: (v) => setState(() => _vib = v), activeColor: Colors.green),
        const SizedBox(height: 30),
        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Save Settings', style: TextStyle(fontSize: 16))),
      ])),
    );
  }

  Widget _tf(TextEditingController c, String l, String h, Color col) => TextField(controller: c, decoration: InputDecoration(labelText: l, hintText: h, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: col))), style: const TextStyle(fontFamily: 'monospace'));

  void _save() async {
    final s = context.read<SettingsProvider>();
    if (_as.text.isEmpty || _as2.text.isEmpty || _vs.text.isEmpty || _vs2.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields required'), backgroundColor: Colors.red)); return; }
    if (_as.text == _as2.text || _vs.text == _vs2.text) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start/Stop must differ'), backgroundColor: Colors.red)); return; }
    await s.updateSettings(audioStartCode: _as.text, audioStopCode: _as2.text, videoStartCode: _vs.text, videoStopCode: _vs2.text, useVibrate: _vib);
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved'), backgroundColor: Colors.green)); Navigator.pop(context); }
  }
}