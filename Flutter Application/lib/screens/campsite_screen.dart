import 'package:card_loading/card_loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/campsite_model.dart';
import 'package:flutter_application_4/screens/Pack_your_bags.dart';
import '../service/auth_service.dart';
import 'package:flutter_application_4/models/user_model.dart';
import 'package:flutter_application_4/screens/map_screen.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:flutter_application_4/service/api.dart';

// Use Spotify color scheme
const kSpotifyBackground = Color(0xFF121212);
const kSpotifyAccent = Color(0xFF1DB954);
const kSpotifyTextPrimary = Color(0xFFFFFFFF);
const kSpotifyTextSecondary = Color(0xFFB3B3B3);
const kSpotifyHighlight = Color(0xFF282828);

class CampsiteScreen extends StatefulWidget {
  final CampsiteModel campsite;
  final AuthService auth;
  final UserModel? user;
  final String? Exp;
  final bool isAnonymous;

  const CampsiteScreen(
      {super.key,
      required this.campsite,
      required this.auth,
      required this.user,
      required this.Exp,
      required this.isAnonymous});

  @override
  _CampsiteScreenState createState() => _CampsiteScreenState();
}

class _CampsiteScreenState extends State<CampsiteScreen> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATER_API_KEY);
  final storage = FirebaseStorage.instance;

  Future<Weather> _fetchWeather(double lat, double lon) async {
    try {
      final w = await _wf.currentWeatherByLocation(lat, lon);
      return w;
    } catch (e) {
      throw Exception("Error fetching weather: $e");
    }
  }

  Future<String> getImageUrl(String imageURL) async {
    final ref = storage.ref().child(imageURL);
    final url = await ref.getDownloadURL();
    return url;
  }

  // Function to show warning dialog
  void showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kSpotifyHighlight,
          title: const Text(
            "สิ่งที่ไม่ควรทำในสถานที่ตั้งแคมป์",
            style: TextStyle(
                color: kSpotifyTextPrimary,
                // fontWeight: FontWeight.bold,
                fontFamily: 'Itim',
                fontSize: 22),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.campsite.warning
                  .map((warning) => Text(
                        '- $warning',
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 17.0,
                            fontFamily: 'Itim'),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                "ปิด",
                style: TextStyle(
                    color: kSpotifyAccent, fontFamily: 'Itim', fontSize: 17),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToPackYourBags(CampsiteModel campsite) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackYourBags(
          campsite: campsite,
          auth: widget.auth,
          user: widget.user,
          Exp: widget.Exp,
          isAnonymous: widget.isAnonymous,
        ),
      ),
    );
  }

  void _navigateToMap(CampsiteModel campsite) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          campsite: campsite,
          userID: widget.auth.currentUser!.uid,
          isAnonymous: widget.isAnonymous,
        ),
      ),
    );
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
        title: Text(
          widget.campsite.name,
          style: const TextStyle(
              color: Color(0xFFFFFFFF), fontSize: 20.0, fontFamily: 'Itim'),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          FutureBuilder<String>(
              future: getImageUrl(widget.campsite.imageURL),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CardLoading(
                    height: 190,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    margin: EdgeInsets.only(bottom: 10),
                  );
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error, color: Colors.red);
                } else {
                  final imageUrl = snapshot.data ?? '';
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: InteractiveViewer(
                              panEnabled:
                                  true, // Set it to false to prevent panning.
                              boundaryMargin: const EdgeInsets.all(0),
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child:
                                    Image.network(imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }
              }),
          FutureBuilder<Weather>(
            future: _fetchWeather(widget.campsite.locationCoordinates.latitude,
                widget.campsite.locationCoordinates.longitude),
            builder: (BuildContext context, AsyncSnapshot<Weather> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CardLoading(
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
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
          const SizedBox(height: 4.0),
          const Text(
            'ค่าบริการ 🪙',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 21.0,
                // fontWeight: FontWeight.bold,
                fontFamily: 'Itim'),
          ),
          const SizedBox(height: 8.0),
          Text(
            "ค่าเข้าผู้ใหญ่: ${widget.campsite.adultEntryFee} บาท",
            style: const TextStyle(
                color: Color(0xFFB3B3B3), fontSize: 17.0, fontFamily: 'Itim'),
          ),
          Text(
            "ค่าเข้าเด็ก: ${widget.campsite.childEntryFee} บาท",
            style: const TextStyle(
                color: Color(0xFFB3B3B3), fontSize: 17.0, fontFamily: 'Itim'),
          ),
          Text(
            "รถยนต์: ${widget.campsite.parkingFee} บาท/คัน",
            style: const TextStyle(
                color: Color(0xFFB3B3B3), fontSize: 17.0, fontFamily: 'Itim'),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'ค่ากางเต็นท์ ⛺',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 21.0,
                // fontWeight: FontWeight.bold,
                fontFamily: 'Itim'),
          ),
          const SizedBox(height: 8.0),
          Text(
            "เริ่มต้น: ${widget.campsite.campingFee} บาท/คืน",
            style: const TextStyle(
                color: Color(0xFFB3B3B3), fontSize: 17.0, fontFamily: 'Itim'),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'การบริการ 🐕‍🦺',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 21.0,
                // fontWeight: FontWeight.bold,
                fontFamily: 'Itim'),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Text(
                'มีที่พัก:',
                style: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 17.0,
                    fontFamily: 'Itim'),
              ),
              const SizedBox(width: 0.0),
              Checkbox(
                value: widget.campsite.accommodationAvailable,
                onChanged: (value) {
                  // Handle the checkbox change
                },
              ),
              const Text(
                'มีเต็นท์ให้บริการ:',
                style: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 17.0,
                    fontFamily: 'Itim'),
              ),
              const SizedBox(width: 0.0),
              Checkbox(
                value: widget.campsite.tentService,
                onChanged: (value) {
                  // Handle the checkbox change
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'กิจกรรม 🎭',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 21.0,
                // fontWeight: FontWeight.bold,
                fontFamily: 'Itim'),
          ),
          const SizedBox(height: 8.0),
          if (widget.campsite.activities.isEmpty)
            const Text(
              'ไม่พบข้อมูล',
              style: TextStyle(
                  color: Color(0xFFB3B3B3), fontSize: 17.0, fontFamily: 'Itim'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.campsite.activities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '- ${widget.campsite.activities[index]}',
                    style: const TextStyle(
                        color: Color(0xFFB3B3B3),
                        fontSize: 17.0,
                        fontFamily: 'Itim'),
                  ),
                );
              },
            ),
          const SizedBox(height: 16.0),
          const Text(
            'ห้องน้ำ 🧼',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 21.0,
                // fontWeight: FontWeight.bold,
                fontFamily: 'Itim'),
          ),
          Row(
            children: [
              const Text(
                'ห้องน้ำสะอาด 🛁:',
                style: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 17.0,
                    fontFamily: 'Itim'),
              ),
              const SizedBox(width: 0.0),
              Checkbox(
                value: widget.campsite.cleanRestrooms,
                onChanged: (value) {
                  // Handle the checkbox change
                },
              ),
              const Text(
                'แยกชายหญิง 🚻:',
                style: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 17.0,
                    fontFamily: 'Itim'),
              ),
              const SizedBox(width: 0.0),
              Checkbox(
                value: widget.campsite.genderSeparatedRestrooms,
                onChanged: (value) {
                  // Handle the checkbox change
                },
              ),
            ],
          ),
          const Text(
            'สัญญานมือถือ 📶',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 21.0,
                // fontWeight: FontWeight.bold,
                fontFamily: 'Itim'),
          ),
          const SizedBox(height: 8.0),
          if (widget.campsite.phoneSignal.isEmpty)
            const Text(
              'ไม่พบข้อมูล',
              style: TextStyle(
                  color: Color(0xFFB3B3B3), fontSize: 17.0, fontFamily: 'Itim'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.campsite.phoneSignal.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    widget.campsite.phoneSignal[index],
                    style: const TextStyle(
                        color: Color(0xFFB3B3B3),
                        fontSize: 17.0,
                        fontFamily: 'Itim'),
                  ),
                );
              },
            ),
          const SizedBox(height: 16.0),
          const Text(
            'ไฟฟ้าต่อพ่วง 🔌',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 21.0,
                // fontWeight: FontWeight.bold,
                fontFamily: 'Itim'),
          ),
          Row(
            children: [
              const Text(
                'ไฟฟ้าต่อพ่วง 🔌:',
                style: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 17.0,
                    fontFamily: 'Itim'),
              ),
              const SizedBox(width: 0.0),
              Checkbox(
                value: widget.campsite.powerAccess,
                onChanged: (value) {
                  // Handle the checkbox change
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'รูปภาพสถานที่ 📷',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 21.0,
                // fontWeight: FontWeight.bold,
                fontFamily: 'Itim'),
          ),
          const SizedBox(height: 8.0),
          if (widget.campsite.campimage.isEmpty)
            const Text(
              'ไม่พบข้อมูล',
              style: TextStyle(
                  color: Color(0xFFB3B3B3), fontSize: 17.0, fontFamily: 'Itim'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.campsite.campimage.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: FutureBuilder<String>(
                      future: getImageUrl(widget.campsite.campimage[index]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CardLoading(
                            height: 100,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            margin: EdgeInsets.only(bottom: 10),
                          );
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error, color: Colors.red);
                        } else {
                          final imageUrl = snapshot.data ?? '';
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: InteractiveViewer(
                                      panEnabled: true,
                                      boundaryMargin: const EdgeInsets.all(0),
                                      minScale: 0.5,
                                      maxScale: 4.0,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                );
              },
            )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF121212),
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.warning_outlined, color: Colors.redAccent),
                onPressed: showWarningDialog,
              ),
              const Spacer(), // Spacer for spacing
              FloatingActionButton.extended(
                onPressed: () {
                  // Navigate to "Pack Your Bags" screen
                  _navigateToPackYourBags(widget.campsite);
                },
                icon: const Icon(Icons.shopping_bag, color: Color(0xFFFFFFFF)),
                heroTag: 'budgets',
                label: const Text(
                  'เตรียมความพร้อม',
                  style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 17,
                      fontFamily: 'Itim'),
                ),
                backgroundColor: kSpotifyAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
              const Spacer(), // Spacer for spacing
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFFFFFFFF)),
                onPressed: () {
                  _navigateToMap(widget.campsite);
                },
              ),
            ],
          ),
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
