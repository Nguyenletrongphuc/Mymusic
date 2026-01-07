import 'package:flutter/material.dart';
import 'pages/my_music_page.dart';
import 'pages/online_page.dart';
import 'pages/search_page.dart';
import 'pages/downloads_page.dart';
import 'package:provider/provider.dart';
import 'providers/music_player_provider.dart';



/// Entry helper to start the app from `main.dart`
void startApp() {
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    MyMusicPage(),
    OnlinePage(),
    SearchPage(),
    DownloadsPage(),
  ];

  @override
@override
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: _pages[_selectedIndex],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.headphones),
          label: "Nhạc của tôi",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: "Trực tuyến",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Tìm kiếm",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download),
          label: "Tải về",
        ),
      ],
    ),
    bottomSheet: _miniPlayer(),
  );
}



  // ---------------------------- MINI PLAYER ---------------------------- //

  Widget _miniPlayer() {
  return Consumer<MusicPlayerProvider>(
  builder: (context, player, _) {
    if (player.currentTitle == null) return const SizedBox();

    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.purple.shade300,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              player.currentTitle!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              player.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: player.togglePlayPause,
          ),
        ],
      ),
    );
  },
);

}

}
