import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

class BarChartShow extends StatefulWidget {
  const BarChartShow({super.key});

  @override
  State<BarChartShow> createState() => _BarChartShowtState();
}

class _BarChartShowtState extends State<BarChartShow> {
  List<int> comments = [];
  List<int> conversations = [];
  List<String> labels = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBarChartData();
  }

  void fetchBarChartData() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token").toString();
    String authorizedBy =
        sharedPreferences.getString("authorized_by").toString();

    String url =
        'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/dash_bar.php';

    Map<String, String> body = {
      "authorized_by": authorizedBy,
    };

    HttpClient httpClient = HttpClient();

    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token);

    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();

    httpClient.close();

    if (response.statusCode == 200) {
      final data = json.decode(reply)["data"]["barGraph"];
      final item1 = data['label'];
      final item2 = data['count']['comment'];
      final item3 = data['count']['conversation'];

      setState(() {
        labels = List<String>.from(item1);
        comments = List<int>.from(item2.map((x) => x as int));
        conversations = List<int>.from(item3.map((x) => x as int));
        isLoading = false;
      });
    } else {
      setState(() {
        comments = [];
        conversations = [];
        labels = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getBarChartColorIndicator(),
        getBody(),
      ],
    );
  }

  Widget getBody() {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    }

    if (comments.isEmpty || conversations.isEmpty || labels.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        margin: const EdgeInsets.only(left: 5, right: 5, top: 0),
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5))),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),
              groupsSpace: 20,
              barGroups: showingBarGroups(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) {
                        return const Text('');
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 16, // space from the bar
                        child: Text(
                          labels[index],
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> showingBarGroups() {
    return List.generate(labels.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: comments[i].toDouble(),
            color: primaryColor,
            width: 15,
            borderRadius: BorderRadius.circular(0),
          ),
          BarChartRodData(
            toY: conversations[i].toDouble(),
            color: grey,
            width: 15,
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      );
    });
  }

  Widget getBarChartColorIndicator() {
    return Card(
        margin: const EdgeInsets.only(left: 5, right: 5, top: 5),
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5))),
        color: Colors.white,
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Comments       : ",
                        style: TextStyle(fontSize: 11.sp)),
                    Container(
                      height: 12.h,
                      width: 40.w,
                      margin: const EdgeInsets.only(right: 20, top: 20),
                      decoration: const BoxDecoration(
                          color: primaryColor, shape: BoxShape.rectangle),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 2.h),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Conversations : ", style: TextStyle(fontSize: 11.sp)),
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      height: 12.h,
                      width: 40.w,
                      decoration: const BoxDecoration(
                          color: grey, shape: BoxShape.rectangle),
                    )
                  ],
                )
              ],
            ),
          ],
        ));
  }
}
