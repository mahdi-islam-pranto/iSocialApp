import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
  Activity name : RealtimeData API Handler
  Project name : iHelpBD CRM
  Auth : Eng. Sk Nayeem ur Rahman
  Designation : Full Stack Software Developer
  Email : nayeemdeveloperbd@gmail.com
*/

class RealTimeData extends StatefulWidget {
  const RealTimeData({Key? key}) : super(key: key);

  @override
  State<RealTimeData> createState() => _RealTimeDataState();
}

class _RealTimeDataState extends State<RealTimeData> {
  List counterValue = [];
  List counterKey = [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCounterValueData();
  }

  void fetchCounterValueData() async {
    setState(() {
      isLoading = true;
    });

    //Show progress dialog
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    //Get user data from local device
    String token = sharedPreferences.getString("token").toString();
    String authorized_by =
        sharedPreferences.getString("authorized_by").toString();
    String username = sharedPreferences.getString("username").toString();
    String role = sharedPreferences.getString("role").toString();

    // Api url
    String url =
        'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/realtime_count.php';

    //Request API body
    Map<String, String> body = {
      "authorized_by": authorized_by,
      "username": username,
      "role": role
    };

    HttpClient httpClient = HttpClient();

    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

    // content type
    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token);

    request.add(utf8.encode(json.encode(body)));

    //Get response
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();

    // Closed request
    httpClient.close();

    //print(reply);

    print(reply);

    if (response.statusCode == 200) {
      setState(() {
        try {
          //set counterValue data

          var length = jsonDecode(reply)['data'].length;

          if (length == 6) {
            //When Sign In as an admin
            counterValue = [
              jsonDecode(reply)['data']['loggedInAgent'],
              jsonDecode(reply)['data']['readyAgent'],
              jsonDecode(reply)['data']['queueTicket'],
              jsonDecode(reply)['data']['newTicket'],
              jsonDecode(reply)['data']['progressTicket'],
              jsonDecode(reply)['data']['closedTicket'],
            ];
            counterKey = [
              "Login",
              "Ready",
              "Queue",
              "New",
              "Progress",
              "Closed"
            ];
          } else {
            //When Sign In as a user
            counterValue = [
              jsonDecode(reply)['data']['queueTicket'],
              jsonDecode(reply)['data']['newTicket'],
              jsonDecode(reply)['data']['progressTicket'],
              jsonDecode(reply)['data']['closedTicket'],
            ];
            counterKey = ["Queue", "New", "Progress", "Closed"];
          }
          isLoading = false;
        } catch (e) {
          isLoading = true;
        }
      });
    } else {
      counterValue = [];
      counterKey = [];
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    try {
      if (counterValue.contains(null) ||
          isLoading ||
          counterKey.contains(null)) {
        return const Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ));
      }

      //Dynamic real time counterValue grid view generator

      return GridView.builder(
        primary: false,
        itemCount: counterValue.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 110,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              border: Border.all(
                  color: Color.fromRGBO(42, 194, 188, 0.4470588235294118),
                  width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Shadow color
                  spreadRadius: 0, // Spread radius
                  blurRadius: 8, // Blur radius
                  offset: Offset(10, 8), // Offset in x and y directions
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  counterKey[index].toString(),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  counterValue[index].toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      return const Center(child: Text("Loading Failed"));
    }
  }
}
