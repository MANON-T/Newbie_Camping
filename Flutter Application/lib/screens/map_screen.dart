import 'dart:async';
import 'package:flutter_application_4/models/campsite_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_application_4/service/api.dart';
import 'package:geolocator/geolocator.dart'; // เพิ่ม library สำหรับการคำนวณระยะทาง

// ใช้ชุดสีของ Spotify
const kSpotifyBackground = Color(0xFF121212);
const kSpotifyAccent = Color(0xFF1DB954);
const kSpotifyTextPrimary = Color(0xFFFFFFFF);
const kSpotifyTextSecondary = Color(0xFFB3B3B3);
const kSpotifyHighlight = Color(0xFF282828);

class MapScreen extends StatefulWidget {
  final CampsiteModel? campsite;
  final String? userID;
  final bool? isAnonymous;
  const MapScreen({super.key, required this.campsite, required this.userID , required this.isAnonymous});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? _pAppPlex;
  LatLng? _currentP;
  final Set<Marker> _markers = {};
  bool _isSnackbarShown =
      false; // ตัวแปรสถานะเพื่อเก็บว่าข้อความได้ถูกแสดงหรือยัง

  void _checkAndSaveLocation() {
    if (_currentP != null && _pAppPlex != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentP!.latitude,
        _currentP!.longitude,
        _pAppPlex!.latitude,
        _pAppPlex!.longitude,
      );

      // สมมุติว่าระยะทางที่ยอมรับได้คือ 50 เมตร
      if (widget.isAnonymous != true) {
        if (distanceInMeters < 50 && !_isSnackbarShown) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "ยินดีด้วยตราปั๊ม ${widget.campsite!.name} ปลดล็อคแล้ว",
            style: const TextStyle(fontFamily: 'Itim', fontSize: 17),
          ),
          backgroundColor: Colors.green,
        ));
        _isSnackbarShown = true; // ตั้งค่าเป็น true เมื่อแสดงข้อความแล้ว
        _saveUserIDToFirebase();
      }
      }
    }
  }

  // ฟังก์ชันบันทึก userID ไปที่ Firebase
  Future<void> _saveUserIDToFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // ค้นหา document ที่ตรงกับเงื่อนไข
    QuerySnapshot querySnapshot = await firestore
        .collection('medal')
        .where('name', isEqualTo: widget.campsite!.name)
        .get();

    // ตรวจสอบว่าได้รับ document มาอย่างน้อยหนึ่งตัว
    if (querySnapshot.docs.isNotEmpty) {
      // สมมุติว่าเราใช้ document แรกที่พบ
      DocumentSnapshot document = querySnapshot.docs.first;

      // อัปเดต field 'user' ของ document ที่พบ
      await firestore.collection('medal').doc(document.id).update({
        'user': FieldValue.arrayUnion([widget.userID])
      }).catchError((error) {
        print("Failed to update user ID: $error");
      });
    } else {
      print("No document found with name ${widget.campsite!.name}");
    }
  }

  Map<PolylineId, Polyline> polylines = {};
  BitmapDescriptor? _currentLocationMarkerIcon;

  @override
  void initState() {
    super.initState();

    if (widget.campsite != null) {
      _pAppPlex = LatLng(
        widget.campsite!.locationCoordinates.latitude,
        widget.campsite!.locationCoordinates.longitude,
      );
    }

    getLocationUpdate();
    _setCustomMarkerIcon();
    _fetchCampsiteLocations();
  }

  void _setCustomMarkerIcon() async {
    _currentLocationMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'images/verified.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSpotifyBackground,
      appBar: AppBar(
        backgroundColor: kSpotifyBackground,
        title: const Text(
          '🗺️ แผนที่สถานที่ตั้งแคมป์',
          style: TextStyle(
              color: kSpotifyTextPrimary, fontSize: 20.0, fontFamily: 'Itim'),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          _currentP == null
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green,))
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) =>
                      _mapController.complete(controller),
                  initialCameraPosition:
                      CameraPosition(target: _currentP!, zoom: 6),
                  markers: {
                    if (_currentP != null)
                      Marker(
                        markerId: const MarkerId("_currentLocation"),
                        icon: _currentLocationMarkerIcon ??
                            BitmapDescriptor.defaultMarker,
                        position: _currentP!,
                      ),
                    if (_pAppPlex != null)
                      Marker(
                        markerId: const MarkerId("_destinationLocation"),
                        icon: BitmapDescriptor.defaultMarker,
                        position: _pAppPlex!,
                      ),
                  }.union(_markers),
                  polylines: Set<Polyline>.of(polylines.values),
                ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              heroTag: '_currentP',
              onPressed: _currentP != null
                  ? () => _cameraToPosition(_currentP!)
                  : null,
              backgroundColor: kSpotifyAccent,
              child: const Icon(Icons.my_location, color: kSpotifyTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(target: pos, zoom: 18);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  Future<void> getLocationUpdate() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          if (_currentP != null) {
            getPolylinePoints().then((coordinate) {
              generatePolylineFromPoint(coordinate);
            });
            _checkAndSaveLocation(); // ตรวจสอบตำแหน่งและบันทึกหากจำเป็น
          }
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    if (_currentP != null && _pAppPlex != null) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          mode: TravelMode.driving,
          origin: PointLatLng(_currentP!.latitude, _currentP!.longitude),
          destination: PointLatLng(_pAppPlex!.latitude, _pAppPlex!.longitude),
        ),
        googleApiKey: GOOGLE_API_KEY,
      );

      if (result.points.isNotEmpty) {
        for (var points in result.points) {
          polylineCoordinates.add(LatLng(points.latitude, points.longitude));
        }
      } else {
        print(result.errorMessage);
      }
    }
    return polylineCoordinates;
  }

  void generatePolylineFromPoint(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<void> _fetchCampsiteLocations() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference campsites = firestore.collection('campsite');

    campsites.get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        GeoPoint location = doc['location_coordinates'];
        LatLng position = LatLng(location.latitude, location.longitude);

        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(doc.id),
            position: position,
            infoWindow: InfoWindow(
              title: doc['name'],
            ),
            icon: BitmapDescriptor.defaultMarker,
          ));
        });
      }
    });
  }
}
