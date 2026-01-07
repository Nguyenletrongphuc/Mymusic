import 'package:flutter/material.dart';
import 'package:mymusic/Mymusic/pages/playlist_page.dart';

class OnlinePage extends StatelessWidget {
  const OnlinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              title: "Toàn Là Nhạc Hot",
              items: hotItems,
            ),
            _section(
              title: "Replay 2025",
              items: replay2025,
            ),
            _section(
              title: "Nhạc Việt",
              items: vietMusic,
            ),
            _section(
              title: "Nhạc Quốc Tế",
              items: international,
            ),
            _section(
              title: "Mùa Giáng Sinh",
              items: christmas,
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= APP BAR ================= */

AppBar _buildAppBar() {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    leading: const Icon(Icons.tune),
    centerTitle: true,
    title: const Text(
      "NCT",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    actions: const [
      Icon(Icons.download),
      SizedBox(width: 16),
      Icon(Icons.notifications_none),
      SizedBox(width: 16),
    ],
  );
}

/* ================= SECTION ================= */

Widget _section({
  required String title,
  required List<Map<String, String>> items,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _playlistCard(context, items[index]);
            },
          ),
        ),
      ],
    ),
  );
}

/* ================= PLAYLIST CARD ================= */

Widget _playlistCard(BuildContext context, Map<String, String> item) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlaylistPage(
            title: item['title']!,
            imageUrl: item['image']!,
          ),
        ),
      );
    },
    child: Container(
      width: 160,
      margin: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['image']!,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['title']!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    ),
  );
}

/* ================= MOCK DATA ================= */

final hotItems = [
  {
    "title": "Top 100 Remix Việt Hay Nhất",
    "image": "https://image-cdn-ak.spotifycdn.com/image/ab67706c0000da84803c396d763d0c968f86923a"
  },
  {
    "title": "Top 100 Nhạc Trẻ Hay Nhất",
    "image": "https://cdn2.fptshop.com.vn/unsafe/1920x0/filters:format(webp):quality(75)/hinh_nen_am_nhac_cover_735bc482b1.png"
  },
  {
    "title": "Top Pop US-UK",
    "image": "https://thienvu.com.vn/image/catalog/tong-hop-nhung-bai-nhac-au-my-us-uk-moi-nhat/tong-hop-ca-bai-hat-au-my-moi-nhat.jpg"
  },
];

final replay2025 = [
  {
    "title": "TOP Thịnh Hành 2025",
    "image": "https://i.imgur.com/9JpJz9Z.jpg"
  },
  {
    "title": "NCT Top Hits 2025",
    "image": "https://i.imgur.com/Yz6KJ5B.jpg"
  },
];

final vietMusic = [
  {
    "title": "Ballad Việt Hay Nhất",
    "image": "https://i.imgur.com/ELbO7mC.jpg"
  },
  {
    "title": "Rap Việt Nổi Bật",
    "image": "https://i.imgur.com/J2Rj6yN.jpg"
  },
  {
    "title": "Indie Việt",
    "image": "https://i.imgur.com/5sR8ZzT.jpg"
  },
];

final international = [
  {
    "title": "US-UK Hot",
    "image": "https://i.imgur.com/9mQZC8y.jpg"
  },
  {
    "title": "K-Pop Hits",
    "image": "https://i.imgur.com/5Zp7x0K.jpg"
  },
  {
    "title": "J-Pop Trending",
    "image": "https://i.imgur.com/bXQyQ9S.jpg"
  },
];

final christmas = [
  {
    "title": "Christmas Hits",
    "image": "https://i.imgur.com/YF6Z9wP.jpg"
  },
  {
    "title": "Noel Chill",
    "image": "https://i.imgur.com/7R9L9Rk.jpg"
  },
  {
    "title": "Nhạc Giáng Sinh Remix",
    "image": "https://i.imgur.com/JcE1p7q.jpg"
  },
];
