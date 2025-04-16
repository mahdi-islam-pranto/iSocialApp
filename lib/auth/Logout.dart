import 'dart:convert';
import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:isocial/data/api_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../view/CustomProgress.dart';
import 'LoginScreen.dart';

/*
  Activity name : Logout API handler
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/

class Logout {
  BuildContext context;

  Logout(this.context);

  // Logout Method
  Future<void> logout() async {
    try {
      // Show logout alert dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Warning"),
          content: const Text('Do you want to logout?',
              style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Call the logout API and clear preferences
                logoutAPI();
                // remove the dialog
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Log error
      debugPrint("Error showing logout dialog: $e");
    }
  }

  // Logout API Method
  Future<void> logoutAPI() async {
    CustomProgress customProgress = CustomProgress(context);
    customProgress.showDialog(
        "Logging out...", SimpleFontelicoProgressDialogType.spinner);
    // Log API call
    debugPrint("Logout API called");

    try {
      // Get SharedPreferences instance
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      // Get token and username from SharedPreferences
      String token = sharedPreferences.getString("token") ?? "";
      String username = sharedPreferences.getString("username") ?? "user1";

      // API URL
      String url = ApiUrls.logoutUrl;

      // device id
      const _androidIdPlugin = AndroidId();

      final String? androidId = await _androidIdPlugin.getId();
      print("Andriod Id:> ${androidId}");

      // Request body
      Map<String, dynamic> body = {
        "username": username,
        "authorized_by": "ihelp20240123idev",
        "device_id": androidId ?? ""
      };

      // Create HTTP client and request
      HttpClient httpClient = HttpClient();
      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

      // Set headers
      request.headers.set('content-type', 'application/json');
      request.headers.set('token', token);

      // Add request body
      request.add(utf8.encode(json.encode(body)));

      // Get response
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();

      // Close HTTP client
      httpClient.close();

      // Parse response
      final data = jsonDecode(reply);

      // Hide progress dialog
      customProgress.hideDialog();

      // Check response status
      if (data['status'] == "200") {
        // Clear SharedPreferences
        await sharedPreferences.clear();

        // Set login status to false
        await sharedPreferences.setBool("loginStatus", false);

        // Navigate to login screen
        // Check if widget is still mounted before navigating
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false);
        }
      }
      // else if (data['status'] == "401") {
      //   // Clear SharedPreferences
      //   await sharedPreferences.clear();
      //   // Set login status to false
      //   await sharedPreferences.setBool("loginStatus", false);
      //   // Navigate to login screen
      //   debugPrint("Logout failed: ${data['data']}");
      //   // navigate to login screen
      //   Navigator.of(context).pushAndRemoveUntil(
      //       MaterialPageRoute(builder: (context) => const LoginScreen()),
      //       (Route<dynamic> route) => false);
      // }
      else {
        // Show error dialog
        // Hide progress dialog
        // customProgress.hideDialog();
        // debugPrint("Logout failed: ${data['data']}");

        // await showErrorDialog(
        //     "Logout Failed",
        //     "${data['data']} + ${data['status']}" ??
        //         "Failed to logout. Please try again.");
        // Clear SharedPreferences
        await sharedPreferences.clear();
        // Set login status to false
        await sharedPreferences.setBool("loginStatus", false);
        // Navigate to login screen
        debugPrint("Logout failed: ${data['data']}");
        // navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false);
      }
    } catch (e) {
      // Hide progress dialog
      customProgress.hideDialog();

      // Show error dialog
      await showErrorDialog("Error", "An error occurred: $e");
      debugPrint("Error during logout: $e");
    }
  }

  Future<void> showErrorDialog(String title, String content) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content, style: const TextStyle(color: Colors.red)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}
