import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../service/auth_service.dart';
import 'package:flutter_application_4/models/campsite_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Budget extends StatefulWidget {
  final AuthService auth;
  final String user;
  final CampsiteModel? campsite;

  const Budget({
    super.key,
    required this.auth,
    required this.user,
    required this.campsite,
  });

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  late double totalCost = 0.0;
  late double enterFee = 0.0;
  late double tentRental = 0.0;
  late double house = 0.0;
  late double campingFee = 0.0;
  late String campsitename = 'Not selected';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.user)
        .get();

    setState(() {
      totalCost = userDoc['totalCost'] ?? 0;
      enterFee = userDoc['enterFee'] ?? 0;
      tentRental = userDoc['tentRental'] ?? 0;
      house = userDoc['house'] ?? 0;
      campingFee = userDoc['campingFee'] ?? 0;
      campsitename = userDoc['campsite'] ?? 'Not selected';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                campsitename,
                style: const TextStyle(
                    fontSize: 26,
                    // fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Itim'),
              ),
              const SizedBox(height: 30),
              AspectRatio(
                aspectRatio: 1.3,
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: totalCost,
                            color: Colors.blue,
                            width: 20,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: enterFee,
                            color: Colors.orange,
                            width: 20,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: tentRental,
                            color: Colors.green,
                            width: 20,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            toY: house,
                            color: Colors.red,
                            width: 20,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [
                          BarChartRodData(
                            toY: campingFee,
                            color: Colors.purple,
                            width: 20,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                    ],
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ค่าใช้จ่ายรวม: ฿${totalCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, color: Colors.blue, fontFamily: 'Itim'),
                  ),
                  Text(
                    'ค่าเข้ารวม: ฿${enterFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, color: Colors.orange, fontFamily: 'Itim'),
                  ),
                  Text(
                    'ค่าเช้าเต้นรวม: ฿${tentRental.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, color: Colors.green, fontFamily: 'Itim'),
                  ),
                  Text(
                    'ค่าเช่าบ้านพักรวม: ฿${house.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, color: Colors.red, fontFamily: 'Itim'),
                  ),
                  Text(
                    'ค่ากางเต้น: ฿${campingFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, color: Colors.purple, fontFamily: 'Itim'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
