import 'package:card_loading/card_loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/medal_model.dart';
import '../service/database.dart';

const kSpotifyBackground = Color(0xFF121212);
const kSpotifyAccent = Color(0xFF1DB954);
const kSpotifyTextPrimary = Color(0xFFFFFFFF);
const kSpotifyTextSecondary = Color(0xFFB3B3B3);
const kSpotifyHighlight = Color(0xFF282828);

class Stampbookpage extends StatefulWidget {
  final String userID;
  const Stampbookpage({super.key, required this.userID});

  @override
  State<Stampbookpage> createState() => _StampbookpageState();
}

class _StampbookpageState extends State<Stampbookpage> {
  final storage = FirebaseStorage.instance;
  Database db = Database.instance;

  Future<String> getImageUrl(String imageURL) async {
    final ref = storage.ref().child(imageURL);
    final url = await ref.getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'สมุดสะสมตราปั๊ม',
          style: TextStyle(
              color: Color(0xFFFFFFFF), fontSize: 20.0, fontFamily: 'Itim'),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: IndexedStack(
          children: [
            StreamBuilder<List<MedalModel>>(
              stream: db.getAllMedalStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: Colors.green,
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'เกิดข้อผิดพลาด: ${snapshot.error}',
                    style: const TextStyle(color: kSpotifyTextPrimary),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    'ไม่มีข้อมูลแคมป์',
                    style: TextStyle(color: kSpotifyTextPrimary),
                  );
                }

                final medals = snapshot.data!;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // จำนวนการ์ดในแต่ละแถว
                    crossAxisSpacing: 8.0, // ระยะห่างระหว่างการ์ดในแนวนอน
                    mainAxisSpacing: 8.0, // ระยะห่างระหว่างการ์ดในแนวตั้ง
                  ),
                  itemCount: medals.length,
                  itemBuilder: (context, index) {
                    final medal = medals[index];
                    final isUnlocked = medal.user.contains(widget.userID);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  'รายละเอียดตราปั้ม',
                                  style: TextStyle(
                                      fontFamily: 'Itim', fontSize: 20),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medal.name,
                                      style: const TextStyle(
                                          fontFamily: 'Itim', fontSize: 17),
                                    ),
                                    const SizedBox(height: 8.0),
                                    FutureBuilder<String>(
                                        future: getImageUrl(isUnlocked
                                            ? medal.unlock
                                            : medal.lock),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CardLoading(
                                              height: 100,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              margin:
                                                  EdgeInsets.only(bottom: 10),
                                            );
                                          } else if (snapshot.hasError) {
                                            return const Icon(Icons.error,
                                                color: Colors.red);
                                          } else {
                                            final imageUrl =
                                                snapshot.data ?? '';
                                            return Center(
                                              child: Container(
                                                width:
                                                    200, // กำหนดความกว้างของรูปภาพ
                                                height:
                                                    200, // กำหนดความสูงของรูปภาพ
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  image: DecorationImage(
                                                    image:
                                                        NetworkImage(imageUrl),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text(
                                      'ปิด',
                                      style: TextStyle(
                                          fontFamily: 'Itim', fontSize: 17),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          color: kSpotifyHighlight,
                          margin: const EdgeInsets.all(4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String>(
                                    future: getImageUrl(
                                        isUnlocked ? medal.unlock : medal.lock),
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
                                        return Center(
                                          child: Container(
                                            width:
                                                200, // กำหนดความกว้างของรูปภาพ
                                            height:
                                                160, // กำหนดความสูงของรูปภาพ
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              image: DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }),
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
