import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class LabelChart extends StatefulWidget {
  const LabelChart({Key? key}) : super(key: key);

  @override
  State<LabelChart> createState() => _LabelChartState();
}

class _LabelChartState extends State<LabelChart> {
  List<double> labels = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchLabelChartData();
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  void fetchLabelChartData() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token") ?? "";
    String authorized_by = sharedPreferences.getString("authorized_by") ?? "";

    String url =
        'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/dash_label.php';

    Map<String, String> body = {
      "authorized_by": authorized_by,
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
      final data = json.decode(reply)["data"]["labelCount"];
      setState(() {
        labels = [
          data['positive'].toDouble(),
          data['negative'].toDouble(),
          data['neutral'].toDouble()
        ];
        isLoading = false;
      });
    } else {
      // If API call fails or response status code is not 200, show default chart
      setState(() {
        labels = [];
        isLoading = false;
      });
    }
  }

  Widget getBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    // If labels data is empty or zero, display outline of the pie chart with color legends
    if (labels.isEmpty || labels.every((element) => element == 0)) {
      return Column(
        children: [
          // Pie chart outline
          AspectRatio(
            aspectRatio: 1.5,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              color: Colors.white,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: 1, // Dummy value
                      title: '',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: 1, // Dummy value
                      title: '',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 1, // Dummy value
                      title: '',
                      radius: 50,
                    ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 0,
                ),
              ),
            ),
          ),
          // Color legends
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(color: Colors.green, text: 'Positive'),
              _buildLegend(color: Colors.red, text: 'Negative'),
              _buildLegend(color: Colors.blue, text: 'Neutral'),
            ],
          ),
        ],
      );
    }

    // If labels data is available, display the pie chart with actual data
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            color: Colors.white,
            child: PieChart(
              PieChartData(
                sections: showingSections(),
                centerSpaceRadius: 40,
                sectionsSpace: 0,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(color: Colors.green, text: 'Positive'),
            _buildLegend(color: Colors.red, text: 'Negative'),
            _buildLegend(color: Colors.blue, text: 'Neutral'),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = false;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green,
            value: labels[0],
            title: '${labels[0]}%',
            radius: radius,
            showTitle: true,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red,
            value: labels[1],
            title: '${labels[1]}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.blue,
            value: labels[2],
            title: '${labels[2]}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        default:
          throw Error();
      }
    });
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: color,
          ),
          SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }
}
