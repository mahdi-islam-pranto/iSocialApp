import 'dart:convert';
import 'dart:developer' as developer;
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

      // Get the data as lists
      List<String> rawLabels = List<String>.from(item1);
      List<int> rawComments = List<int>.from(item2.map((x) => x as int));
      List<int> rawConversations = List<int>.from(item3.map((x) => x as int));

      // If there are too many bars, limit to the most recent ones
      // to prevent overcrowding (7 is a good number for weekly data)
      const int maxBars = 7;
      if (rawLabels.length > maxBars) {
        developer.log(
            'Limiting chart to $maxBars most recent dates out of ${rawLabels.length}');
        rawLabels = rawLabels.sublist(rawLabels.length - maxBars);
        rawComments = rawComments.sublist(rawComments.length - maxBars);
        rawConversations =
            rawConversations.sublist(rawConversations.length - maxBars);
      }

      setState(() {
        labels = rawLabels;
        comments = rawComments;
        conversations = rawConversations;
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
      aspectRatio: 1.2, // Adjusted aspect ratio to give more height for labels
      child: Card(
        margin: const EdgeInsets.only(left: 5, right: 5, top: 0),
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5))),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              10, 20, 20, 30), // Increased bottom padding for labels
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),
              groupsSpace: 16, // Reduced group space
              barGroups: showingBarGroups(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize:
                        30, // Increase reserved size for rotated labels
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) {
                        return const Text('');
                      }

                      // Format the date label to be more compact
                      String formattedLabel = _formatDateLabel(labels[index]);

                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8, // Reduced space from the bar
                        angle: -45, // Rotate labels for better fit
                        child: Text(
                          formattedLabel,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
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
            width: 12, // Reduced width to allow more space between bars
            borderRadius: BorderRadius.circular(0),
          ),
          BarChartRodData(
            toY: conversations[i].toDouble(),
            color: grey,
            width: 12, // Reduced width to allow more space between bars
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      );
    });
  }

  // Helper method to format date labels
  String _formatDateLabel(String label) {
    // Try to detect if this is a date and format it appropriately
    try {
      // Check if the label contains date-like patterns
      if (label.contains('-') || label.contains('/')) {
        // Try to parse the date
        DateTime? date;

        // Handle different date formats
        if (label.contains('-')) {
          // Try yyyy-MM-dd format
          List<String> parts = label.split('-');
          if (parts.length == 3) {
            date = DateTime.tryParse(label);
          }
        } else if (label.contains('/')) {
          // Try dd/MM/yyyy format
          List<String> parts = label.split('/');
          if (parts.length == 3) {
            // Rearrange to yyyy-MM-dd for parsing
            date = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
          }
        }

        if (date != null) {
          // Format to a more compact representation
          return '${date.day}/${date.month}';
        }
      }
    } catch (e) {
      // If any error occurs during parsing, return the original label
      developer.log('Error formatting date label: $e');
    }

    // If not a recognizable date or parsing failed, return original or truncated
    return label.length > 5 ? label.substring(0, 5) : label;
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
