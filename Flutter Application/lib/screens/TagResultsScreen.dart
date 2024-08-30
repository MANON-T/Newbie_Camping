import 'package:card_loading/card_loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/campsite_model.dart';
import 'package:flutter_application_4/service/database.dart';
import 'package:flutter_application_4/screens/campsite_screen.dart';
import '../service/auth_service.dart';
import 'package:flutter_application_4/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:flutter_application_4/service/api.dart';

// ใช้ชุดสีของ Spotify
const kSpotifyBackground = Color(0xFF121212);
const kSpotifyAccent = Color(0xFF1DB954);
const kSpotifyTextPrimary = Color(0xFFFFFFFF);
const kSpotifyTextSecondary = Color(0xFFB3B3B3);
const kSpotifyHighlight = Color(0xFF282828);

class TagResultsScreen extends StatefulWidget {
  final String tag;
  final AuthService auth;
  final UserModel? user;
  final String? Exp;
  final bool isAnonymous;

  const TagResultsScreen(
      {super.key,
      required this.tag,
      required this.auth,
      required this.user,
      required this.Exp,
      required this.isAnonymous});

  @override
  _TagResultsScreenState createState() => _TagResultsScreenState();
}

class _TagResultsScreenState extends State<TagResultsScreen> {
  List<CampsiteModel> _campsites = [];
  final storage = FirebaseStorage.instance;

  final WeatherFactory _wf = WeatherFactory(OPENWEATER_API_KEY);

  @override
  void initState() {
    super.initState();
    _getCampsitesByTag();
  }

  Future<String> getImageUrl(String imageURL) async {
    final ref = storage.ref().child(imageURL);
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<Weather> _fetchWeather(double lat, double lon) async {
    try {
      final w = await _wf.currentWeatherByLocation(lat, lon);
      return w;
    } catch (e) {
      throw Exception("Error fetching weather: $e");
    }
  }

  Future<void> _getCampsitesByTag() async {
    try {
      List<CampsiteModel> campsites =
          await Database.instance.getCampsitesByTag([widget.tag]);
      setState(() {
        _campsites = campsites;
      });
    } catch (e) {
      print('Error getting campsites by tag: $e');
    }
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.tag,
          style: const TextStyle(
              fontSize: 22.0,
              color: kSpotifyTextPrimary,
              // fontWeight: FontWeight.bold,
              fontFamily: 'Itim'),
        ),
        backgroundColor: kSpotifyBackground,
      ),
      backgroundColor: kSpotifyBackground,
      body: ListView.builder(
        itemCount: _campsites.length,
        itemBuilder: (context, index) {
          CampsiteModel campsite = _campsites[index];
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
                margin: const EdgeInsets.all(4.0), // ลดระยะของการ์ด
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // ลดระยะภายในการ์ด
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                          future: getImageUrl(campsite.imageURL),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CardLoading(
                                height: 100,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                margin: EdgeInsets.only(bottom: 10),
                              );
                            } else if (snapshot.hasError) {
                              return const Icon(Icons.error, color: Colors.red);
                            } else {
                              final imageUrl = snapshot.data ?? '';
                              return Container(
                                height: 120, // ลดขนาดของรูปภาพ
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                          }),
                      if (index == 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '✨ แนะนำ',
                            style: TextStyle(
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
                        subtitle: Text(
                          'คะแนน: ${campsite.campscore}',
                          style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 14.0,
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
                              height: 100,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              margin: EdgeInsets.only(bottom: 10),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            final weather = snapshot.data!;
                            return _buildUI(weather);
                          } else {
                            return const Text('No weather data available');
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
