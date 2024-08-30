import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/campsite_model.dart';
import 'package:flutter_application_4/screens/backpack_screen.dart';
import '../service/auth_service.dart';
import 'package:flutter_application_4/models/user_model.dart';

// Use Spotify color scheme
const kSpotifyBackground = Color(0xFF121212);
const kSpotifyAccent = Color(0xFF1DB954);
const kSpotifyTextPrimary = Color(0xFFFFFFFF);
const kSpotifyTextSecondary = Color(0xFFB3B3B3);
const kSpotifyHighlight = Color(0xFF282828);

class PackYourBags extends StatefulWidget {
  final CampsiteModel campsite;
  final AuthService auth;
  final UserModel? user;
  final String? Exp;
  final bool isAnonymous;

  const PackYourBags(
      {super.key,
      required this.campsite,
      required this.auth,
      required this.user,
      required this.Exp,
      required this.isAnonymous});

  @override
  _PackYourBagsState createState() => _PackYourBagsState();
}

class _PackYourBagsState extends State<PackYourBags> {
  // Add counters for adults, children, cars, tents, and houses
  int _adultCount = 0;
  int _childrenCount = 0;
  int _carCount = 0;
  bool _campingChecked = false;
  bool _houseChecked = false;
  bool _rentTentChecked = false;
  String? _tentSize;
  String? _houseSize;
  int _nightCount = 1;

  // Add counters for tent and house sizes
  int _smallTentCount = 0;
  int _mediumTentCount = 0;
  int _largeTentCount = 0;
  int _smallHouseCount = 0;
  int _mediumHouseCount = 0;
  int _largeHouseCount = 0;

  final List<String> _tentSizes = [
    "แบบเล็ก (2 คน)",
    "แบบกลาง (4 คน)",
    "แบบใหญ่ (6 คน)"
  ];
  final List<String> _houseSizes = [
    "แบบเล็ก (2-3 คน)",
    "แบบกลาง (4-6 คน)",
    "แบบใหญ่ (8-10 คน)"
  ];

  void _incrementTent(String size) {
    setState(() {
      if (size == "แบบเล็ก (2 คน)") {
        _smallTentCount++;
      } else if (size == "แบบกลาง (4 คน)") {
        _mediumTentCount++;
      } else if (size == "แบบใหญ่ (6 คน)") {
        _largeTentCount++;
      }
    });
  }

  void _decrementTent(String size) {
    setState(() {
      if (size == "แบบเล็ก (2 คน)" && _smallTentCount > 0) {
        _smallTentCount--;
      } else if (size == "แบบกลาง (4 คน)" && _mediumTentCount > 0) {
        _mediumTentCount--;
      } else if (size == "แบบใหญ่ (6 คน)" && _largeTentCount > 0) {
        _largeTentCount--;
      }
    });
  }

  void _incrementHouse(String size) {
    setState(() {
      if (size == "แบบเล็ก (2-3 คน)") {
        _smallHouseCount++;
      } else if (size == "แบบกลาง (4-6 คน)") {
        _mediumHouseCount++;
      } else if (size == "แบบใหญ่ (8-10 คน)") {
        _largeHouseCount++;
      }
    });
  }

  void _decrementHouse(String size) {
    setState(() {
      if (size == "แบบเล็ก (2-3 คน)" && _smallHouseCount > 0) {
        _smallHouseCount--;
      } else if (size == "แบบกลาง (4-6 คน)" && _mediumHouseCount > 0) {
        _mediumHouseCount--;
      } else if (size == "แบบใหญ่ (8-10 คน)" && _largeHouseCount > 0) {
        _largeHouseCount--;
      }
    });
  }

  void _increment(int type) {
    setState(() {
      if (type == 1) {
        _adultCount++;
      } else if (type == 2) {
        _childrenCount++;
      } else if (type == 3) {
        _carCount++;
      } else if (type == 4) {
        _nightCount++;
      }
    });
  }

  void _decrement(int type) {
    setState(() {
      if (type == 1 && _adultCount > 0) {
        _adultCount--;
      } else if (type == 2 && _childrenCount > 0) {
        _childrenCount--;
      } else if (type == 3 && _carCount > 0) {
        _carCount--;
      } else if (type == 4 && _nightCount > 1) {
        _nightCount--;
      }
    });
  }

  Widget _buildTentCounter(String size, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            size,
            style: const TextStyle(
                color: kSpotifyTextPrimary, fontSize: 20.0, fontFamily: 'Itim'),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: kSpotifyAccent),
                onPressed: () => _decrementTent(size),
              ),
              Text(
                '$count',
                style: const TextStyle(
                    color: kSpotifyTextPrimary,
                    fontSize: 20.0,
                    fontFamily: 'Itim'),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: kSpotifyAccent),
                onPressed: () => _incrementTent(size),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHouseCounter(String size, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            size,
            style: const TextStyle(
                color: kSpotifyTextPrimary, fontSize: 20.0, fontFamily: 'Itim'),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: kSpotifyAccent),
                onPressed: () => _decrementHouse(size),
              ),
              Text(
                '$count',
                style: const TextStyle(
                    color: kSpotifyTextPrimary,
                    fontSize: 20.0,
                    fontFamily: 'Itim'),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: kSpotifyAccent),
                onPressed: () => _incrementHouse(size),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, int count, int type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: kSpotifyTextPrimary, fontSize: 20.0, fontFamily: 'Itim'),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: kSpotifyAccent),
                onPressed: () => _decrement(type),
              ),
              Text(
                '$count',
                style: const TextStyle(
                    color: kSpotifyTextPrimary,
                    fontSize: 20.0,
                    fontFamily: 'Itim'),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: kSpotifyAccent),
                onPressed: () => _increment(type),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDetailsText(int type) {
    switch (type) {
      case 1:
        return 'ค่าบริการต่อผู้ใหญ่: ${widget.campsite.adultEntryFee} บาท';
      case 2:
        return 'ค่าบริการต่อเด็ก: ${widget.campsite.childEntryFee} บาท';
      case 3:
        return 'ค่าบริการต่อรถยนต์: ${widget.campsite.parkingFee} บาท';
      default:
        return '';
    }
  }

  double _TentRentalCost(double value) {
    return value;
  }

  double _HouseCost(double value) {
    return value;
  }

  double tentcost = 0.0;
  double housecost = 0.0;

  double calculateTotalCost() {
    // Logic to calculate total cost goes here
    // No need to declare tentcost and housecost again
    tentcost = 0.0;
    housecost = 0.0;

    // Example calculation:
    tentcost += _smallTentCount * widget.campsite.tent_rental[0] * _nightCount;
    tentcost += _mediumTentCount * widget.campsite.tent_rental[1] * _nightCount;
    tentcost += _largeTentCount * widget.campsite.tent_rental[2] * _nightCount;
    housecost += _smallHouseCount * widget.campsite.house[0] * _nightCount;
    housecost += _mediumHouseCount * widget.campsite.house[1] * _nightCount;
    housecost += _largeHouseCount * widget.campsite.house[2] * _nightCount;

    double totalcost = tentcost + housecost;
    return totalcost;
  }

  double _enterFeeCalculate() {
    return (_adultCount * widget.campsite.adultEntryFee) +
        (_childrenCount * widget.campsite.childEntryFee) +
        (_carCount * widget.campsite.parkingFee);
  }

  double _calculateTentRentalCost() {
    if (!_campingChecked || !_rentTentChecked || _tentSize == null) return 0.0;

    switch (_tentSize) {
      case "แบบเล็ก (2 คน)":
        return widget.campsite.tent_rental[0] * _nightCount;
      case "แบบกลาง (4 คน)":
        return widget.campsite.tent_rental[1] * _nightCount;
      case "แบบใหญ่ (6 คน)":
        return widget.campsite.tent_rental[2] * _nightCount;
      default:
        return 0.0;
    }
  }

  double _calculateHouseCost() {
    if (!_houseChecked || _houseSize == null) return 0.0;

    switch (_houseSize) {
      case "แบบเล็ก (2-3 คน)":
        return widget.campsite.house[0] * _nightCount;
      case "แบบกลาง (4-6 คน)":
        return widget.campsite.house[1] * _nightCount;
      case "แบบใหญ่ (8-10 คน)":
        return widget.campsite.house[2] * _nightCount;
      default:
        return 0.0;
    }
  }

  double _calculateCampingFee() {
    return _campingChecked ? widget.campsite.campingFee * _nightCount : 0.0;
  }

  double _calculateTotalCost() {
    return _enterFeeCalculate() + calculateTotalCost() + _calculateCampingFee();
  }

  @override
  Widget build(BuildContext context) {
    // Filter tent rental and house costs that are not zero
    final availableTentSizes = _tentSizes
        .asMap()
        .entries
        .where((entry) => widget.campsite.tent_rental[entry.key] != 0)
        .map((entry) => entry.value)
        .toList();

    final availableHouseSizes = _houseSizes
        .asMap()
        .entries
        .where((entry) => widget.campsite.house[entry.key] != 0)
        .map((entry) => entry.value)
        .toList();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kSpotifyBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kSpotifyTextPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: kSpotifyBackground,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "คำนวนค่าใช้จ่าย",
              style: TextStyle(
                  color: kSpotifyTextPrimary,
                  fontSize: 20.0,
                  fontFamily: 'Itim'),
            ),
            Text(
              'รวม: ${_calculateTotalCost().toStringAsFixed(2)} บาท',
              style: const TextStyle(
                  color: kSpotifyTextPrimary,
                  fontSize: 18.0,
                  fontFamily: 'Itim'),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: kSpotifyHighlight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: kSpotifyAccent, width: 1.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'ค่าเข้า ',
                            style: TextStyle(
                                color: kSpotifyTextPrimary,
                                fontSize: 26.0,
                                // fontWeight: FontWeight.bold,
                                fontFamily: 'Itim'),
                          ),
                          Text(
                            '💰',
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        _getDetailsText(1), // "ค่าบริการต่อผู้ใหญ่"
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 16.0,
                            fontFamily: 'Itim'),
                      ),
                      Text(
                        _getDetailsText(2), // "ค่าบริการต่อเด็ก"
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 16.0,
                            fontFamily: 'Itim'),
                      ),
                      Text(
                        _getDetailsText(3), // "ค่าบริการต่อรถยนต์"
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 16.0,
                            fontFamily: 'Itim'),
                      ),
                      const SizedBox(height: 20.0),
                      const Divider(color: kSpotifyTextSecondary),
                      _buildCounter("ผู้ใหญ่", _adultCount, 1),
                      _buildCounter("เด็ก", _childrenCount, 2),
                      _buildCounter("รถยนต์", _carCount, 3),
                      const SizedBox(height: 20.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: kSpotifyHighlight,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: kSpotifyAccent),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'จำนวนคืน',
                              style: TextStyle(
                                  color: kSpotifyTextPrimary,
                                  fontSize: 20.0,
                                  fontFamily: 'Itim'),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: kSpotifyAccent),
                                  onPressed: () => _decrement(4),
                                ),
                                Text(
                                  '$_nightCount คืน',
                                  style: const TextStyle(
                                      color: kSpotifyTextPrimary,
                                      fontSize: 20.0,
                                      fontFamily: 'Itim'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: kSpotifyAccent),
                                  onPressed: () => _increment(4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                color: kSpotifyHighlight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: kSpotifyAccent, width: 1.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'ค่าที่พัก ',
                            style: TextStyle(
                                color: kSpotifyTextPrimary,
                                fontSize: 26.0,
                                // fontWeight: FontWeight.bold,
                                fontFamily: 'Itim'),
                          ),
                          Text(
                            '🏕️',
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'ค่าบริการกางเต็นท์: ${widget.campsite.campingFee} บาท/คืน',
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 16.0,
                            fontFamily: 'Itim'),
                      ),
                      Text(
                        'เช่าเต็นท์: ${widget.campsite.tentService ? "ให้บริการ" : "ไม่มีบริการ"}',
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 16.0,
                            fontFamily: 'Itim'),
                      ),
                      Text(
                        'เช่าบ้านพัก: ${widget.campsite.accommodationAvailable ? "ให้บริการ" : "ไม่มีบริการ"}',
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 16.0,
                            fontFamily: 'Itim'),
                      ),
                      const SizedBox(height: 20.0),
                      const Divider(color: kSpotifyTextSecondary),
                      CheckboxListTile(
                        title: const Text(
                          'ตั้งแคมป์',
                          style: TextStyle(
                              color: kSpotifyTextPrimary,
                              fontSize: 20.0,
                              fontFamily: 'Itim'),
                        ),
                        value: _campingChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _campingChecked = value ?? false;
                            if (!_campingChecked) {
                              _rentTentChecked = false;
                              _tentSize = null;
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: kSpotifyAccent,
                      ),
                      if (_campingChecked)
                        CheckboxListTile(
                          title: const Text(
                            'ต้องการเช่าเต็นท์',
                            style: TextStyle(
                                color: kSpotifyTextPrimary,
                                fontSize: 20.0,
                                fontFamily: 'Itim'),
                          ),
                          value: _rentTentChecked,
                          onChanged: _campingChecked
                              ? (bool? value) {
                                  setState(() {
                                    _rentTentChecked = value ?? false;
                                    if (!_rentTentChecked) {
                                      _tentSize = null;
                                    }
                                  });
                                }
                              : null,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: kSpotifyAccent,
                        ),
                      if (_campingChecked &&
                          _rentTentChecked &&
                          widget.campsite.tentService)
                        Column(
                          children: availableTentSizes.map((size) {
                            int count = 0;
                            if (size == "แบบเล็ก (2 คน)") {
                              count = _smallTentCount;
                            }
                            if (size == "แบบกลาง (4 คน)") {
                              count = _mediumTentCount;
                            }
                            if (size == "แบบใหญ่ (6 คน)") {
                              count = _largeTentCount;
                            }
                            return _buildTentCounter(size, count);
                          }).toList(),
                        ),
                      CheckboxListTile(
                        title: const Text(
                          'เช้าบ้านพัก',
                          style: TextStyle(
                              color: kSpotifyTextPrimary,
                              fontSize: 20.0,
                              fontFamily: 'Itim'),
                        ),
                        value: _houseChecked,
                        onChanged: widget.campsite.accommodationAvailable
                            ? (value) {
                                setState(() {
                                  _houseChecked = value ?? false;
                                });
                              }
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: kSpotifyAccent,
                      ),
                      if (_houseChecked &&
                          widget.campsite.accommodationAvailable)
                        Column(
                          children: availableHouseSizes.map((size) {
                            int count = 0;
                            if (size == "แบบเล็ก (2-3 คน)") {
                              count = _smallHouseCount;
                            }
                            if (size == "แบบกลาง (4-6 คน)") {
                              count = _mediumHouseCount;
                            }
                            if (size == "แบบใหญ่ (8-10 คน)") {
                              count = _largeHouseCount;
                            }
                            return _buildHouseCounter(size, count);
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                color: kSpotifyHighlight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: kSpotifyAccent, width: 1.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'รายละเอียด ',
                            style: TextStyle(
                                color: kSpotifyTextPrimary,
                                fontSize: 26.0,
                                // fontWeight: FontWeight.bold,
                                fontFamily: 'Itim'),
                          ),
                          Text(
                            '📝',
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'จำนวนผู้ใหญ่: $_adultCount คน, ${widget.campsite.adultEntryFee * _adultCount} บาท',
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 18.0,
                            fontFamily: 'Itim'),
                      ),
                      Text(
                        'จำนวนเด็ก: $_childrenCount คน, ${widget.campsite.childEntryFee * _childrenCount} บาท',
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 18.0,
                            fontFamily: 'Itim'),
                      ),
                      Text(
                        'จำนวนรถยนต์: $_carCount คัน, ${widget.campsite.parkingFee * _carCount} บาท',
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 18.0,
                            fontFamily: 'Itim'),
                      ),
                      const Divider(color: kSpotifyTextSecondary),
                      Text(
                        'จำนวนคืน: $_nightCount คืน',
                        style: const TextStyle(
                            color: kSpotifyTextSecondary,
                            fontSize: 18.0,
                            fontFamily: 'Itim'),
                      ),
                      if (_campingChecked)
                        Text(
                          'กางเต็นท์: ${widget.campsite.campingFee * _nightCount} บาท',
                          style: const TextStyle(
                              color: kSpotifyTextSecondary,
                              fontSize: 18.0,
                              fontFamily: 'Itim'),
                        ),
                      if (_campingChecked && _rentTentChecked)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_smallTentCount > 0)
                              Text(
                                'เช่าเต็นท์แบบเล็ก: $_smallTentCount เต็นท์, ${(widget.campsite.tent_rental[0] * _smallTentCount * _nightCount).toStringAsFixed(2)} บาท',
                                style: const TextStyle(
                                    color: kSpotifyTextSecondary,
                                    fontSize: 18.0,
                                    fontFamily: 'Itim'),
                              ),
                            if (_mediumTentCount > 0)
                              Text(
                                'เช่าเต็นท์แบบกลาง: $_mediumTentCount เต็นท์, ${(widget.campsite.tent_rental[1] * _mediumTentCount * _nightCount).toStringAsFixed(2)} บาท',
                                style: const TextStyle(
                                    color: kSpotifyTextSecondary,
                                    fontSize: 18.0,
                                    fontFamily: 'Itim'),
                              ),
                            if (_largeTentCount > 0)
                              Text(
                                'เช่าเต็นท์แบบใหญ่: $_largeTentCount เต็นท์, ${(widget.campsite.tent_rental[2] * _largeTentCount * _nightCount).toStringAsFixed(2)} บาท',
                                style: const TextStyle(
                                    color: kSpotifyTextSecondary,
                                    fontSize: 18.0,
                                    fontFamily: 'Itim'),
                              ),
                          ],
                        ),
                      if (_houseChecked)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_smallHouseCount > 0)
                              Text(
                                'เช่าบ้านพักแบบเล็ก: $_smallHouseCount หลัง, ${(widget.campsite.house[0] * _smallHouseCount * _nightCount).toStringAsFixed(2)} บาท',
                                style: const TextStyle(
                                    color: kSpotifyTextSecondary,
                                    fontSize: 18.0,
                                    fontFamily: 'Itim'),
                              ),
                            if (_mediumHouseCount > 0)
                              Text(
                                'เช่าบ้านพักแบบกลาง: $_mediumHouseCount หลัง, ${(widget.campsite.house[1] * _mediumHouseCount * _nightCount).toStringAsFixed(2)} บาท',
                                style: const TextStyle(
                                    color: kSpotifyTextSecondary,
                                    fontSize: 18.0,
                                    fontFamily: 'Itim'),
                              ),
                            if (_largeHouseCount > 0)
                              Text(
                                'เช่าบ้านพักแบบใหญ่: $_largeHouseCount หลัง, ${(widget.campsite.house[2] * _largeHouseCount * _nightCount).toStringAsFixed(2)} บาท',
                                style: const TextStyle(
                                    color: kSpotifyTextSecondary,
                                    fontSize: 18.0,
                                    fontFamily: 'Itim'),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              if (!widget.isAnonymous)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Backpack(
                                  Exp: widget.Exp,
                                  totalCost: _calculateTotalCost(),
                                  enterFee: _enterFeeCalculate(),
                                  tentRental: tentcost,
                                  house: housecost,
                                  campingFee: _calculateCampingFee(),
                                  campsite: widget.campsite,
                                  auth: widget.auth,
                                  user: widget.user,
                                )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          kSpotifyAccent, // เปลี่ยนสีพื้นหลังของปุ่มเป็นสีเขียว
                    ),
                    child: const Text(
                      'จัดสัมภาระ',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Itim',
                          fontSize: 17),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
