import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class MyMusicPage extends StatefulWidget {
  const MyMusicPage({super.key});

  @override
  State<MyMusicPage> createState() => _MyMusicPageState();
}

class _MyMusicPageState extends State<MyMusicPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  static const _channel = MethodChannel('music_scan');

  final AudioPlayer _player = AudioPlayer();

  List<Map<String, String>> _songs = [];
  bool _loading = true;
  String? _playingPath;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    _loadSongs();
  }

  Future<void> _loadSongs() async {
  setState(() => _loading = true);

  try {
    final List result = await _channel.invokeMethod('scanMp3');

    _songs = result.map<Map<String, String>>((item) {
      final map = Map<String, dynamic>.from(item);
      return {
        'title': map['title']?.toString() ?? 'Không tên',
        'path': map['path']?.toString() ?? '',
      };
    }).toList();

  } catch (e) {
    _songs = [];
  }

  setState(() => _loading = false);
}


  Future<void> _playSong(Map<String, String> song) async {
    final path = song['path'];
    if (path == null) return;

    try {
      if (_playingPath == path && _player.playing) {
        await _player.pause();
        setState(() {});
        return;
      }

      await _player.setAudioSource(
        AudioSource.uri(Uri.file(path)),
      );
      await _player.play();
      setState(() => _playingPath = path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể phát file')),
      );
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _searchBar(),
          const SizedBox(height: 10),
          TabBar(
            controller: tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            isScrollable: true,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(text: "Bài hát"),
              Tab(text: "Video"),
              Tab(text: "Ca sĩ"),
              Tab(text: "Album"),
              Tab(text: "Thư mục"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _songListView(),
                _emptyView("Video"),
                _emptyView("Ca sĩ"),
                _emptyView("Album"),
                _emptyView("Thư mục"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ---------------- //

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Bài hát, danh sách phát và nghệ sĩ",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _songListView() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_songs.isEmpty) {
      return const Center(child: Text('Ở đây trống rỗng'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: _songs.length,
      itemBuilder: (_, i) {
        final s = _songs[i];
        final title = s['title'] ?? 'Không tên';
        final path = s['path'];
        final isPlaying = _playingPath == path && _player.playing;

        return ListTile(
          leading: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.blue.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: const Text('MP3'),
          trailing: Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle,
          ),
          onTap: () => _playSong(s),
        );
      },
    );
  }

  Widget _emptyView(String name) {
    return Center(child: Text("Không có $name"));
  }
}
