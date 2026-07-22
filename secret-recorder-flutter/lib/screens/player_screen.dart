import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/recorder_provider.dart';
import '../security/encryption_service.dart';

class PlayerScreen extends StatefulWidget {
  final RecordedFile recording;

  const PlayerScreen({super.key, required this.recording});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _audioPlayer = AudioPlayer();
      
      // Decrypt file to temp directory
      final tempDir = Directory.systemTemp;
      final decryptedFile = File('${tempDir.path}/${widget.recording.fileName}');
      
      await EncryptionService.decryptFile(
        widget.recording.filePath,
        decryptedFile.path,
      );
      
      await _audioPlayer!.setFilePath(decryptedFile.path);
      
      _audioPlayer!.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration ?? Duration.zero;
          });
        }
      });
      
      _audioPlayer!.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });
      
      _audioPlayer!.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load file: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recording.fileName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Decrypting and loading...'),
                ],
              )
            : _error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  )
                : _buildPlayer(),
      ),
    );
  }

  Widget _buildPlayer() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // File Info
          Icon(
            widget.recording.isAudio ? Icons.audiotrack : Icons.videocam,
            size: 80,
            color: widget.recording.isAudio ? Colors.green : Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            widget.recording.fileName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.recording.formattedSize,
            style: const TextStyle(color: Colors.grey),
          ),
          
          const SizedBox(height: 32),
          
          // Progress Bar
          Slider(
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
            onChanged: (value) {
              _audioPlayer?.seek(Duration(seconds: value.toInt()));
            },
            activeColor: Colors.green,
          ),
          
          // Time Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 40,
                onPressed: () {
                  final newPos = _position - const Duration(seconds: 10);
                  _audioPlayer?.seek(newPos.isNegative ? Duration.zero : newPos);
                },
              ),
              
              const SizedBox(width: 24),
              
              // Play/Pause
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  iconSize: 48,
                  color: Colors.white,
                  onPressed: () {
                    if (_isPlaying) {
                      _audioPlayer?.pause();
                    } else {
                      _audioPlayer?.play();
                    }
                  },
                ),
              ),
              
              const SizedBox(width: 24),
              
              // Forward
              IconButton(
                icon: const Icon(Icons.forward_10),
                iconSize: 40,
                onPressed: () {
                  final newPos = _position + const Duration(seconds: 10);
                  _audioPlayer?.seek(newPos > _duration ? _duration : newPos);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Stop Button
          ElevatedButton(
            onPressed: () {
              _audioPlayer?.stop();
              _audioPlayer?.seek(Duration.zero);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
