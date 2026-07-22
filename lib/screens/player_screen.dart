import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/recorder_provider.dart';
import '../security/encryption_service.dart';

class PlayerScreen extends StatefulWidget {
  final RecordedFile recording;
  const PlayerScreen({super.key, required this.recording});
  @override State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  AudioPlayer? _player;
  bool _playing = false;
  bool _loading = true;
  Duration _dur = Duration.zero;
  Duration _pos = Duration.zero;
  String? _err;

  @override void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    try {
      _player = AudioPlayer();
      final tmp = File('${Directory.systemTemp.path}/${widget.recording.fileName}');
      await EncryptionService.decryptFile(widget.recording.filePath, tmp.path);
      await _player!.setFilePath(tmp.path);
      _player!.durationStream.listen((d) { if (mounted) setState(() => _dur = d ?? Duration.zero); });
      _player!.positionStream.listen((p) { if (mounted) setState(() => _pos = p); });
      _player!.playerStateStream.listen((s) { if (mounted) setState(() => _playing = s.playing); });
      if (mounted) setState(() => _loading = false);
    } catch (e) { if (mounted) setState(() { _loading = false; _err = e.toString(); }); }
  }

  @override void dispose() { _player?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recording.fileName)),
      body: Center(child: _loading ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Decrypting...')]) : _err != null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error, size: 64, color: Colors.red), const SizedBox(height: 16), Text(_err!, style: const TextStyle(color: Colors.red))]) : _build()),
    );
  }

  Widget _build() {
    return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(widget.recording.isAudio ? Icons.audiotrack : Icons.videocam, size: 80, color: widget.recording.isAudio ? Colors.green : Colors.blue),
      const SizedBox(height: 24),
      Text(widget.recording.fileName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 32),
      Slider(value: _pos.inSeconds.toDouble(), max: (_dur.inSeconds.toDouble()).clamp(1, double.infinity), onChanged: (v) => _player?.seek(Duration(seconds: v.toInt())), activeColor: Colors.green),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_fmt(_pos), style: const TextStyle(color: Colors.grey)), Text(_fmt(_dur), style: const TextStyle(color: Colors.grey))]),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(icon: const Icon(Icons.replay_10), iconSize: 40, onPressed: () { final n = _pos - const Duration(seconds: 10); _player?.seek(n.isNegative ? Duration.zero : n); }),
        const SizedBox(width: 24),
        Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green), child: IconButton(icon: Icon(_playing ? Icons.pause : Icons.play_arrow), iconSize: 48, color: Colors.white, onPressed: () { _playing ? _player?.pause() : _player?.play(); })),
        const SizedBox(width: 24),
        IconButton(icon: const Icon(Icons.forward_10), iconSize: 40, onPressed: () { final n = _pos + const Duration(seconds: 10); _player?.seek(n > _dur ? _dur : n); }),
      ]),
      const SizedBox(height: 32),
      ElevatedButton(onPressed: () { _player?.stop(); _player?.seek(Duration.zero); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Stop')),
    ]));
  }

  String _fmt(Duration d) { final m = d.inMinutes.remainder(60).toString().padLeft(2, '0'); final s = d.inSeconds.remainder(60).toString().padLeft(2, '0'); return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s'; }
}