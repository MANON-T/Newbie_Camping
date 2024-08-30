import 'package:card_loading/card_loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/tip_model.dart';
import '../service/database.dart';
import 'package:flutter_application_4/screens/tip_read_screen.dart';

// ใช้ชุดสีของ Spotify
const kSpotifyBackground = Color(0xFF121212);
const kSpotifyAccent = Color(0xFF1DB954);
const kSpotifyTextPrimary = Color(0xFFFFFFFF);
const kSpotifyTextSecondary = Color(0xFFB3B3B3);
const kSpotifyHighlight = Color(0xFF282828);

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreen();
}

class _TipScreen extends State<TipScreen> {
  final storage = FirebaseStorage.instance;

  Database db = Database.instance;
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<String> getImageUrl(String imageURL) async {
    final ref = storage.ref().child(imageURL);
    final url = await ref.getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSpotifyBackground,
      appBar: AppBar(
        backgroundColor: kSpotifyBackground,
        title: const Text(
          '🥴 เกล็ดความรู้สำหรับคุณ',
          style: TextStyle(
              color: kSpotifyTextPrimary, fontSize: 20.0, fontFamily: 'Itim'),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            StreamBuilder<List<TipModel>>(
              stream: db.getallTipStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.green,);
                } else if (snapshot.hasError) {
                  return Text(
                    'เกิดข้อผิดพลาด: ${snapshot.error}',
                    style: const TextStyle(color: kSpotifyTextPrimary),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    'ไม่มีข้อมูลทิป',
                    style: TextStyle(color: kSpotifyTextPrimary),
                  );
                }

                final tips = snapshot.data!;
                return ListView.builder(
                  itemCount: tips.length,
                  itemBuilder: (context, index) {
                    final tip = tips[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Card(
                        color: kSpotifyHighlight,
                        margin: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TipReadScreen(
                                        tipModel: tip,
                                      )),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FutureBuilder<String>(
                                    future: getImageUrl(tip.imageURL),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CardLoading(
                                          height: 100,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          margin: EdgeInsets.only(bottom: 10),
                                        );
                                      } else if (snapshot.hasError) {
                                        return const Icon(Icons.error,
                                            color: Colors.red);
                                      } else {
                                        final imageUrl = snapshot.data ?? '';
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // กำหนดความมนของขอบ
                                          child: SizedBox(
                                            width:
                                                400.0, // กำหนดความกว้างของรูปภาพ
                                            height:
                                                200.0, // กำหนดความสูงของรูปภาพ
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit
                                                  .cover, // ปรับขนาดรูปภาพให้พอดีกับขนาดที่กำหนด
                                            ),
                                          ),
                                        );
                                      }
                                    }),
                                const SizedBox(height: 8.0),
                                Text(
                                  tip.topic,
                                  style: const TextStyle(
                                    color: kSpotifyTextPrimary,
                                    fontSize: 22.0,
                                    fontFamily: 'Itim',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
