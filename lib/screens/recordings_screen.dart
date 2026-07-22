import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recorder_provider.dart';
import 'player_screen.dart';

class RecordingsScreen extends StatelessWidget {
  const RecordingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recordings'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: Consumer<RecorderProvider>(builder: (context, r, _) {
        if (r.recordings.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.folder_off, size: 64, color: Colors.grey), SizedBox(height: 16), Text('No recordings yet', style: TextStyle(color: Colors.grey, fontSize: 18))]));
        return ListView.builder(padding: const EdgeInsets.all(8), itemCount: r.recordings.length, itemBuilder: (context, i) {
          final f = r.recordings[i];
          return Card(margin: const EdgeInsets.symmetric(vertical: 4), child: ListTile(
            leading: Icon(f.isAudio ? Icons.audiotrack : Icons.videocam, color: f.isAudio ? Colors.green : Colors.blue),
            title: Text(f.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${f.formattedSize} • ${f.createdAt.day}/${f.createdAt.month} ${f.createdAt.hour}:${f.createdAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.play_arrow), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(recording: f)))),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete?'), content: Text(f.fileName), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), TextButton(onPressed: () { r.deleteRecording(f); Navigator.pop(ctx); }, child: const Text('Delete', style: TextStyle(color: Colors.red)))]))),
            ]),
          ));
        });
      }),
    );
  }
}