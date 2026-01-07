import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';

class PlaylistPage extends StatefulWidget {
  final String title;
  final String imageUrl;

  const PlaylistPage({super.key, required this.title, required this.imageUrl});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late Future<List<Map<String, dynamic>>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = fetchSongs();
  }

  Future<List<Map<String, dynamic>>> fetchSongs() async {
    final uri = Uri.parse('http://192.168.1.9:8000/api/music');
    final resp = await http.get(uri).timeout(const Duration(seconds: 15));

    if (resp.statusCode != 200) {
      throw Exception('Server returned ${resp.statusCode}');
    }

    final data = json.decode(resp.body);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e)));
    }

    if (data is Map && data['songs'] is List) {
      return List<Map<String, dynamic>>.from(data['songs'].map((e) => Map<String, dynamic>.from(e)));
    }

    throw Exception('Unexpected response format');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(widget.imageUrl, fit: BoxFit.cover),
                Container(
                  color: Colors.black26,
                ),
                Center(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _songsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Lỗi tải danh sách: ${snapshot.error}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() => _songsFuture = fetchSongs()),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                final songs = snapshot.data ?? [];
                if (songs.isEmpty) {
                  return const Center(child: Text('Không có bài hát nào')); 
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: songs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final s = songs[index];
                    final rawTitle = s['title'] ?? s['name'] ?? 'Không rõ tiêu đề';
                    final displayTitle = rawTitle.endsWith('.mp3') ? rawTitle.substring(0, rawTitle.length - 4) : rawTitle;
                    final subtitle = s['artist'] ?? s['singer'] ?? '';

                    // Watch player state so UI updates when playback changes
                    final player = context.watch<MusicPlayerProvider>();
                    final isCurrent = player.currentTitle == displayTitle;

                    return ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(displayTitle),
                      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                      trailing: IconButton(
                        icon: Icon(
                          isCurrent && player.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: isCurrent && player.isPlaying ? Colors.green : null,
                        ),
                        onPressed: () async {
                          final controller = context.read<MusicPlayerProvider>();

                          // If this is current track, toggle play/pause
                          if (isCurrent) {
                            await controller.togglePlayPause();
                            return;
                          }

                          // Otherwise start playing this track
                          final fileName = rawTitle.endsWith('.mp3') ? rawTitle : '$rawTitle.mp3';
                          final encoded = Uri.encodeComponent(fileName);
                          final url = 'http://192.168.1.9:8000/api/music/$encoded/data';

                          try {
                            await controller.play(url, displayTitle);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đang phát: $displayTitle')),
                              );
                            }
                          } catch (e) {
                            debugPrint('PLAYER ERROR: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Không thể phát: $e')),
                              );
                            }
                          }
                        },
                      ),
                      onTap: () async {
                        // Mirror same behavior as play button: start the track
                        final controller = context.read<MusicPlayerProvider>();
                        final fileName = rawTitle.endsWith('.mp3') ? rawTitle : '$rawTitle.mp3';
                        final encoded = Uri.encodeComponent(fileName);
                        final url = 'http://192.168.1.9:8000/api/music/$encoded/data';

                        try {
                          await controller.play(url, displayTitle);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đang phát: $displayTitle')),
                            );
                          }
                        } catch (e) {
                          debugPrint('PLAYER ERROR: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Không thể phát: $e')),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
