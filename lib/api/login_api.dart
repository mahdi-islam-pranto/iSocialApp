// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
// import '../progress_indicator/custom_progress_indicator.dart';
// import '../view/Dashboard.dart';

 /// barchart and levelchart version problem ajjonno hide kore dice but app run perfectly


// new changed tiketlist + convertutionview + template 21/3/2024

// // Sk Nayeem Ur Rahman
// // git push --set-upstream origin main
//
//
// class LoginAPI {
//   final BuildContext context;
//
//   LoginAPI(this.context);
//
//   // Login method
//   Future<void> login(String email, String password) async {
//     CustomProgressIndicator customProgress = CustomProgressIndicator(context);
//     try {
//       customProgress.showDialog(
//           "Please wait", SimpleFontelicoProgressDialogType.spinner);
//
//       //Api url
//       String url = 'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/login.php';
//
//       /// Device Token
//       //String deviceToken = await NotificationServices().getDeviceToken();
//       //Authentication
//       Map<String, String> body = {
//         "email": email,
//         "password": password,
//         //  "device_id": deviceToken
//       };
//
//       HttpClient httpClient = HttpClient();
//
//       HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
//
//       // content type
//       request.headers.set('Content-Type', 'application/json');
//
//       request.add(utf8.encode(json.encode(body)));
//
//       //Get response
//       HttpClientResponse response = await request.close();
//       String reply = await response.transform(utf8.decoder).join();
//
//       // Closed request
//       httpClient.close();
//
//       final data = jsonDecode(reply);
//       print(data);
//
//       //print("Device Token Is : ${deviceToken}");
//
//       //Check response code
//       if (data["status"].toString().contains("200")) {
//         // Parse jason data
//
//         SharedPreferences sharedPreferences =
//             await SharedPreferences.getInstance();
//
//         //Store token in local device
//         sharedPreferences.setString("token", data['data']['token']);
//         sharedPreferences.setString("token", data['data']['authorized_by']);
//
//
//         /// Token
//
//         print(data['data']['token']);
//         print('...................token...............');
//
//         // authorized_by
//         print("authorized_by");
//
//         print(data['data']['authorized_by']);
//
//         // Store login status
//         sharedPreferences.setBool("loginStatus", true);
//
//         //Store username
//         sharedPreferences.setString(
//             "username", data['data']['username'].toString());
//
//         //Store userId
//         sharedPreferences.setString(
//             "userId", data['data']['userId'].toString());
//
//         //Store email
//         sharedPreferences.setString("email", email);
//
//         //role
//         sharedPreferences.setString("role", data['data']['role'].toString());
//
//         //token_expire_date
//         sharedPreferences.setString(
//             "token_expire_date", data['data']['token_expire_date'].toString());
//
//         //Hide progress
//         customProgress.hideDialog();
//
//         //Switch to DashboardScreen
//         // ignore: use_build_context_synchronously
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => const DashBoardScreen()));
//       } else {
//         //Hide progress
//         customProgress.hideDialog();
//         // ignore: use_build_context_synchronously
//         await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text("Login Error"),
//             content:
//                 Text(data["data"], style: const TextStyle(color: Colors.red)),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('Ok'),
//               ),
//             ],
//           ),
//         );
//         //Hide progress
//         // customProgress.hideDialog();
//       }
//     } catch (e) {
//       //Hide progress
//       customProgress.hideDialog();
//
//       await showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Login Error"),
//           content:
//               Text(e.toString(), style: const TextStyle(color: Colors.red)),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Ok'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }
