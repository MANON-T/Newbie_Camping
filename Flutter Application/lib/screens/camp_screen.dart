import 'dart:async';
import 'package:card_loading/card_loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/campsite_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import '../service/database.dart';
import 'package:flutter_application_4/screens/campsite_screen.dart';
import 'package:flutter_application_4/Widgets/suggestion.dart';
import '../service/auth_service.dart';
import 'package:flutter_application_4/models/user_model.dart';
import 'package:flutter_application_4/service/api.dart';

const kSpotifyBackground = Color(0xFF121212);
const kSpotifyAccent = Color(0xFF1DB954);
const kSpotifyTextPrimary = Color(0xFFFFFFFF);
const kSpotifyTextSecondary = Color(0xFFB3B3B3);
const kSpotifyHighlight = Color(0xFF282828);

class CampScreen extends StatefulWidget {
  final AuthService auth;
  final UserModel? user;
  final String? Exp;
  final bool isAnonymous;
  const CampScreen({
    super.key,
    required this.auth,
    required this.user,
    required this.Exp,
    required this.isAnonymous,
  });

  @override
  State<CampScreen> createState() => _CampScreen();
}

class _CampScreen extends State<CampScreen> {
  final storage = FirebaseStorage.instance;

  Database db = Database.instance;
  final int _selectedIndex = 0;
  List<CampsiteModel> suggestedCampsites = [];
  CampsiteModel? topRecommendedCampsite;

  late StreamSubscription<DocumentSnapshot> _userTagStreamSubscription;

  final WeatherFactory _wf = WeatherFactory(OPENWEATER_API_KEY);

  @override
  void initState() {
    super.initState();
    _listenToUserTags();
  }

  Future<String> getImageUrl(String imageURL) async {
    final ref = storage.ref().child(imageURL);
    final url = await ref.getDownloadURL();
    return url;
  }

  void _listenToUserTags() {
    final uid = widget.auth.currentUser!.uid;
    _userTagStreamSubscription = FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .snapshots()
        .listen((userDoc) async {
      List<String> userTags = List.from(userDoc.data()?['tag'] ?? []);
      if (userTags.isNotEmpty) {
        suggestedCampsites = await getSuggestedCampsites(userTags);
        setState(() {});
      }
    });
  }

  Future<Weather> _fetchWeather(double lat, double lon) async {
    try {
      final w = await _wf.currentWeatherByLocation(lat, lon);
      return w;
    } catch (e) {
      throw Exception("Error fetching weather: $e");
    }
  }

  @override
  void dispose() {
    _userTagStreamSubscription.cancel();
    super.dispose();
  }

  Future<List<CampsiteModel>> getSuggestedCampsites(
      List<String> userTags) async {
    QuerySnapshot campsiteSnapshot =
        await FirebaseFirestore.instance.collection('campsite').get();
    List<CampsiteModel> suggestedCampsites = [];
    int maxMatchCount = 0;

    for (QueryDocumentSnapshot doc in campsiteSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> suggesTags = List.from(data['sugges_tag'] ?? []);
      int matchCount = suggesTags.where((tag) => userTags.contains(tag)).length;

      if (matchCount > maxMatchCount) {
        maxMatchCount = matchCount;
        suggestedCampsites = [CampsiteModel.fromDocument(doc)];
        topRecommendedCampsite = CampsiteModel.fromDocument(doc);
      } else if (matchCount == maxMatchCount) {
        suggestedCampsites.add(CampsiteModel.fromDocument(doc));
      }
    }
    return suggestedCampsites;
  }

  void _navigateToCampsiteScreen(CampsiteModel campsite) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampsiteScreen(
          campsite: campsite,
          auth: widget.auth,
          user: widget.user,
          Exp: widget.Exp,
          isAnonymous: widget.isAnonymous,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSpotifyBackground,
      appBar: AppBar(
        backgroundColor: kSpotifyBackground,
        title: const Text(
          '🏕️ ยินดีต้อนรับสู่แคมป์',
          style: TextStyle(
            color: kSpotifyTextPrimary,
            fontSize: 20.0,
            fontFamily: 'Itim',
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: kSpotifyTextPrimary),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CampsiteSearchDelegate(
                  auth: widget.auth,
                  user: widget.user,
                  Exp: widget.Exp,
                  isAnonymous: widget.isAnonymous,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            StreamBuilder<List<CampsiteModel>>(
              stream: db.getAllCampsiteStream(),
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
                    'ไม่มีข้อมูลแคมป์',
                    style: TextStyle(color: kSpotifyTextPrimary),
                  );
                }

                final campsites = snapshot.data!;
                final hasTopRecommendedCampsite =
                    topRecommendedCampsite != null;

                List<CampsiteModel> displayCampsites = [];

                if (hasTopRecommendedCampsite) {
                  // Add the top recommended campsite first
                  displayCampsites.add(topRecommendedCampsite!);
                  // Add the remaining campsites excluding the top recommended one
                  displayCampsites.addAll(campsites.where((campsite) =>
                      campsite.name != topRecommendedCampsite!.name));
                } else {
                  // Show all campsites as usual
                  displayCampsites = campsites;
                }

                return ListView.builder(
                  itemCount: displayCampsites.length,
                  itemBuilder: (context, index) {
                    final campsite = displayCampsites[index];
                    String recommendationText = '';

                    if (hasTopRecommendedCampsite && index == 0) {
                      recommendationText = '✨ แนะนำสำหรับคุณ';
                    } else if (topRecommendedCampsite == null && index == 0) {
                      recommendationText = '✨ แนะนำ';
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: InkWell(
                        onTap: () {
                          _navigateToCampsiteScreen(campsite);
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
                                    future: getImageUrl(campsite.imageURL),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CardLoading(
                                          height: 110,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          margin: EdgeInsets.only(bottom: 10),
                                        );
                                      } else if (snapshot.hasError) {
                                        return const Icon(Icons.error,
                                            color: Colors.red);
                                      } else {
                                        final imageUrl = snapshot.data ?? '';
                                        return Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      }
                                    }),
                                if (recommendationText.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(
                                      recommendationText,
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color: kSpotifyAccent,
                                        fontFamily: 'Itim',
                                      ),
                                    ),
                                  ),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                    horizontal: 8.0,
                                  ),
                                  title: Text(
                                    campsite.name,
                                    style: const TextStyle(
                                      color: kSpotifyTextPrimary,
                                      fontSize: 17.0,
                                      fontFamily: 'Itim',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 9),
                                  child: Text(
                                    'แท็ก: #${campsite.tag.join(" #")}',
                                    style: const TextStyle(
                                      color: Colors.cyan,
                                      fontFamily: 'Itim',
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                FutureBuilder<Weather>(
                                  future: _fetchWeather(
                                      campsite.locationCoordinates.latitude,
                                      campsite.locationCoordinates.longitude),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Weather> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CardLoading(
                                        height: 40,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        margin: EdgeInsets.only(bottom: 10),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      final weather = snapshot.data!;
                                      return _buildUI(weather);
                                    } else {
                                      return const Text(
                                          'No weather data available');
                                    }
                                  },
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

  Widget _buildUI(Weather weather) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              _weatherIcon(weather),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.08,
              ),
              _currentTemp(weather),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationHeader(Weather weather) {
    return Text(
      weather.areaName ?? "",
      style: const TextStyle(
          fontFamily: 'Itim', color: Colors.white, fontSize: 17),
    );
  }

  Widget _dateTimeInfo(Weather weather) {
    if (weather.date == null) {
      return const Text(
        'No weather data available',
        style: TextStyle(fontFamily: 'Itim', color: Colors.white, fontSize: 17),
      );
    }

    DateTime now = weather.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(
              fontFamily: 'Itim', color: Colors.white, fontSize: 17),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(
                  fontFamily: 'Itim', color: Colors.white, fontSize: 17),
            ),
            Text(
              " ${DateFormat("d.M.y").format(now)}",
              style: const TextStyle(
                  fontFamily: 'Itim', color: Colors.white, fontSize: 17),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon(Weather weather) {
    final Map<String, String> weatherDescriptionMap = {
      // Thunderstorm
      'thunderstorm with light rain': 'พายุฝนฟ้าคะนองมีฝนตกเบา',
      'thunderstorm with rain': 'พายุฝนฟ้าคะนองมีฝนตก',
      'thunderstorm with heavy rain': 'พายุฝนฟ้าคะนองมีฝนตกหนัก',
      'light thunderstorm': 'พายุฝนฟ้าคะนองเบา',
      'thunderstorm': 'พายุฝนฟ้าคะนอง',
      'heavy thunderstorm': 'พายุฝนฟ้าคะนองหนัก',
      'ragged thunderstorm': 'พายุฝนฟ้าคะนองรุนแรง',
      'thunderstorm with light drizzle': 'พายุฝนฟ้าคะนองมีฝนปรอยๆเบา',
      'thunderstorm with drizzle': 'พายุฝนฟ้าคะนองมีฝนปรอยๆ',
      'thunderstorm with heavy drizzle': 'พายุฝนฟ้าคะนองมีฝนปรอยๆหนัก',

      // Drizzle
      'light intensity drizzle': 'ฝนปรอยๆเบา',
      'drizzle': 'ฝนปรอยๆ',
      'heavy intensity drizzle': 'ฝนปรอยๆหนัก',
      'light intensity drizzle rain': 'ฝนปรอยๆเบาพร้อมฝน',
      'drizzle rain': 'ฝนปรอยๆพร้อมฝน',
      'heavy intensity drizzle rain': 'ฝนปรอยๆหนักพร้อมฝน',
      'shower rain and drizzle': 'ฝนตกพร้อมฝนปรอยๆ',
      'heavy shower rain and drizzle': 'ฝนตกหนักพร้อมฝนปรอยๆ',
      'shower drizzle': 'ฝนตกพร้อมฝนปรอยๆเบา',

      // Rain
      'light rain': 'ฝนตกเบา',
      'moderate rain': 'ฝนตกปานกลาง',
      'heavy intensity rain': 'ฝนตกหนัก',
      'very heavy rain': 'ฝนตกหนักมาก',
      'extreme rain': 'ฝนตกหนักมาก',
      'freezing rain': 'ฝนเยือกแข็ง',
      'light intensity shower rain': 'ฝนตกเบาพร้อมฝนตกเบา',
      'shower rain': 'ฝนตกพร้อมฝนตก',
      'heavy intensity shower rain': 'ฝนตกหนักพร้อมฝนตกหนัก',
      'ragged shower rain': 'ฝนตกหนักพร้อมฝนตกหนักรุนแรง',

      // Snow
      'light snow': 'หิมะตกเบา',
      'snow': 'หิมะตก',
      'heavy snow': 'หิมะตกหนัก',
      'sleet': 'หิมะละลาย',
      'light shower sleet': 'หิมะละลายเบา',
      'shower sleet': 'หิมะละลาย',
      'light rain and snow': 'ฝนและหิมะตกเบา',
      'rain and snow': 'ฝนและหิมะตก',
      'light shower snow': 'หิมะตกเบา',
      'shower snow': 'หิมะตก',
      'heavy shower snow': 'หิมะตกหนัก',

      // Atmosphere
      'mist': 'หมอก',
      'smoke': 'ควัน',
      'haze': 'ฝุ่น',
      'sand/ dust whirls': 'พายุทราย/ฝุ่น',
      'fog': 'หมอกหนา',
      'sand': 'ทราย',
      'dust': 'ฝุ่น',
      'volcanic ash': 'เถ้าภูเขาไฟ',
      'squalls': 'ลมกระโชก',
      'tornado': 'พายุทอร์นาโด',

      // Clear
      'clear sky': 'ท้องฟ้าแจ่มใส',

      // Clouds
      'few clouds': 'เมฆบางส่วน',
      'scattered clouds': 'เมฆกระจาย',
      'broken clouds': 'เมฆเป็นบางส่วน',
      'overcast clouds': 'เมฆครอบคลุม'
    };

    String getWeatherDescription(String? description) {
      if (description == null) {
        return 'ไม่มีข้อมูล';
      }
      return weatherDescriptionMap[description] ?? description;
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      "https://openweathermap.org/img/wn/${weather.weatherIcon}@4x.png"))),
        ),
        Text(
          getWeatherDescription(weather.weatherDescription),
          style: const TextStyle(
              fontFamily: 'Itim', color: Colors.white, fontSize: 17),
        )
      ],
    );
  }

  Widget _currentTemp(Weather weather) {
    return Text(
      "อุณหภูมิปัจจุบัน ${weather.temperature?.celsius?.toStringAsFixed(0)} ํ C",
      style: const TextStyle(
          fontFamily: 'Itim', color: Colors.white, fontSize: 17),
    );
  }

  Widget _extarInfo(Weather weather) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.80,
      decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "อุณหภูมิสูงสุด: ${weather.tempMax?.celsius?.toStringAsFixed(0)} ํ C",
                style: const TextStyle(
                    fontFamily: 'Itim', color: Colors.white, fontSize: 17),
              ),
              Text(
                "อุณหภูมิต่ำสุด: ${weather.tempMin?.celsius?.toStringAsFixed(0)} ํ C",
                style: const TextStyle(
                    fontFamily: 'Itim', color: Colors.white, fontSize: 17),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "ความเร็วลม: ${weather.windSpeed?.toStringAsFixed(0)} m/s",
                style: const TextStyle(
                    fontFamily: 'Itim', color: Colors.white, fontSize: 17),
              ),
              Text(
                "ความชื้น: ${weather.humidity?.toStringAsFixed(0)} %",
                style: const TextStyle(
                    fontFamily: 'Itim', color: Colors.white, fontSize: 17),
              )
            ],
          )
        ],
      ),
    );
  }
}

class CampsiteSearchDelegate extends SearchDelegate {
  final AuthService auth;
  final UserModel? user;
  final String? Exp;
  final bool isAnonymous;
  CampsiteSearchDelegate(
      {required this.auth,
      required this.user,
      required this.Exp,
      required this.isAnonymous});

  Database db = Database.instance;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white, // cursor color
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
            decorationThickness: 0.0000001, // input text underline
            color: Colors.white // input text color
            ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, null);
      },
    );
  }

  // Method to build the Suggestion widget
  Widget buildSuggestionWidget(BuildContext context) {
    return Suggestion(
      auth: auth,
      user: user,
      Exp: Exp,
      isAnonymous: isAnonymous,
    ); // Use your Suggestion widget here
  }

  @override
  Widget buildResults(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: db.searchCampsitesByName(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green,)
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'เกิดข้อผิดพลาด',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'ไม่พบผลลัพธ์',
                style: TextStyle(color: Colors.white , fontFamily: 'Itim' , fontSize: 17),
              ),
            );
          }

          final campsites = snapshot.data!;
          return ListView.builder(
            itemCount: campsites.length,
            itemBuilder: (context, index) {
              final campsite = campsites[index];
              return ListTile(
                title: Text(
                  campsite.name,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Itim', fontSize: 17),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CampsiteScreen(
                          campsite: campsite,
                          auth: auth,
                          user: user,
                          Exp: Exp,
                          isAnonymous: isAnonymous),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildSuggestionWidget(context), // Display the Suggestion widget
        Container(
          height: 16,
          color: Colors.black,
        ), // Add some space between suggestion and results
        Expanded(
          child: buildResults(context), // Display the search results
        ),
      ],
    );
  }
}
