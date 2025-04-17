import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

// Removed unused import
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
  Activity name : RealtimeData API Handler
  Project name : iHelpBD CRM
  Auth : Eng. Sk Nayeem ur Rahman, Mahdi Islam Pranto
  Designation : Full Stack Software Developer
  Email : nayeemdeveloperbd@gmail.com
*/

// Global key to access the RealTimeData state
// We're using a string key to avoid private type issues
final GlobalKey realTimeDataKey = GlobalKey(debugLabel: 'RealTimeDataKey');

class RealTimeData extends StatefulWidget {
  const RealTimeData({Key? key}) : super(key: key);

  @override
  State<RealTimeData> createState() => _RealTimeDataState();

  // Static method to refresh all instances
  static void refreshAll({bool silent = true}) {
    developer.log(
        '🔄 REALTIME DATA: Static refresh method called (silent: $silent)');
    // Set the flag to refresh on next build
    _RealTimeDataState.needsRefresh = true;
    developer
        .log('🔄 REALTIME DATA: Set needsRefresh flag for next build cycle');

    // Force immediate refresh of any existing instances
    // This is a workaround to ensure the API is called every time
    for (final state in _RealTimeDataState._activeInstances) {
      if (state.mounted) {
        developer.log('🔄 REALTIME DATA: Forcing refresh on active instance');
        state.fetchCounterValueData(showLoading: false);
      }
    }
  }
}

// Keep track of all active instances of the widget
class _RealTimeDataState extends State<RealTimeData> {
  // Static list to track all active instances
  static final List<_RealTimeDataState> _activeInstances = [];

  List counterValue = [];
  List counterKey = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Register this instance
    _activeInstances.add(this);
    developer.log(
        '🔄 REALTIME DATA: Instance registered (total: ${_activeInstances.length})');
    fetchCounterValueData();
  }

  @override
  void dispose() {
    // Unregister this instance
    _activeInstances.remove(this);
    developer.log(
        '🔄 REALTIME DATA: Instance unregistered (remaining: ${_activeInstances.length})');
    super.dispose();
  }

  // Timestamp to track when the data was last refreshed
  DateTime? lastRefreshTime;

  // Flag to force refresh on next build
  static bool needsRefresh = false;

  @override
  void didUpdateWidget(RealTimeData oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if we need to refresh
    if (needsRefresh) {
      developer.log(
          '🔄 REALTIME DATA: Detected needsRefresh flag, refreshing data silently');
      needsRefresh = false;
      fetchCounterValueData(showLoading: false);
    }
  }

  void fetchCounterValueData({bool showLoading = true}) async {
    final now = DateTime.now();
    developer.log('🔄 REALTIME DATA: Fetching data at ${now.toString()}');

    if (lastRefreshTime != null) {
      final difference = now.difference(lastRefreshTime!).inSeconds;
      developer.log(
          '⏱️ REALTIME DATA: Time since last refresh: $difference seconds');
    }

    // Only show loading indicator for manual refreshes
    if (showLoading) {
      setState(() {
        isLoading = true;
      });
    }

    //Show progress dialog
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    //Get user data from local device
    String token = sharedPreferences.getString("token").toString();
    String authorizedBy =
        sharedPreferences.getString("authorized_by").toString();
    String username = sharedPreferences.getString("username").toString();
    String role = sharedPreferences.getString("role").toString();

    // Api url
    String url =
        'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/realtime_count.php';

    //Request API body
    Map<String, String> body = {
      "authorized_by": authorizedBy,
      "username": username,
      "role": role
    };

    developer.log('📤 REALTIME DATA: Sending request with body: $body');

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

    developer
        .log('📥 REALTIME DATA: Response status code: ${response.statusCode}');
    developer.log('📥 REALTIME DATA: Response data: $reply');

    // Add a more visible log message with timestamp for easier tracking
    // Use print for more visibility in the console
    print('\n==================================================');
    print('🕒 REALTIME DATA REFRESH AT: ${DateTime.now().toString()}');
    print('📊 RESPONSE CODE: ${response.statusCode}');
    try {
      var jsonData = jsonDecode(reply);
      print('📊 DATA SUMMARY:');
      if (jsonData['data'] != null) {
        // Print each key-value pair for better visibility
        jsonData['data'].forEach((key, value) {
          print('   $key: $value');
        });
      } else {
        print('   No data found in response');
      }
    } catch (e) {
      print('   Error parsing response: $e');
      print('   Raw response: $reply');
    }
    print('==================================================\n');

    // Also log to developer.log for completeness
    developer.log('🕒 REALTIME DATA API RESPONSE RECEIVED');
    developer.log('📊 Response code: ${response.statusCode}');

    if (response.statusCode == 200) {
      setState(() {
        try {
          //set counterValue data
          var jsonResponse = jsonDecode(reply);
          var length = jsonResponse['data'].length;

          // Store previous values for comparison
          List oldCounterValue = List.from(counterValue);

          if (length == 6) {
            //When Sign In as an admin
            counterValue = [
              jsonResponse['data']['loggedInAgent'],
              jsonResponse['data']['readyAgent'],
              jsonResponse['data']['queueTicket'],
              jsonResponse['data']['newTicket'],
              jsonResponse['data']['progressTicket'],
              jsonResponse['data']['closedTicket'],
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
              jsonResponse['data']['queueTicket'],
              jsonResponse['data']['newTicket'],
              jsonResponse['data']['progressTicket'],
              jsonResponse['data']['closedTicket'],
            ];
            counterKey = ["Queue", "New", "Progress", "Closed"];
          }

          // Log changes in values
          if (oldCounterValue.isNotEmpty &&
              oldCounterValue.length == counterValue.length) {
            bool hasChanges = false;
            String changesLog = '\n\n🔴 DATA CHANGES DETECTED:';

            for (int i = 0; i < counterValue.length; i++) {
              if (oldCounterValue[i] != counterValue[i]) {
                hasChanges = true;
                changesLog +=
                    '\n   ${counterKey[i]}: ${oldCounterValue[i]} → ${counterValue[i]}';
                developer.log(
                    '🔄 REALTIME DATA: ${counterKey[i]} changed from ${oldCounterValue[i]} to ${counterValue[i]}');
              }
            }

            if (hasChanges) {
              changesLog +=
                  '\n\n🔴 This confirms the auto-refresh is working and updating data!';
              developer.log(changesLog);
            } else {
              developer
                  .log('\n\n🔵 NO DATA CHANGES: Values are the same as before');
            }
          } else {
            developer.log(
                '🔄 REALTIME DATA: Initial data loaded or structure changed');
          }

          // Always set isLoading to false, regardless of showLoading parameter
          isLoading = false;
          lastRefreshTime = now;
          developer.log(
              '✅ REALTIME DATA: Successfully updated at ${now.toString()}');
        } catch (e) {
          developer.log('❌ REALTIME DATA: Error parsing response: $e');
          // Only set isLoading to true if showLoading was true
          if (showLoading) {
            isLoading = true;
          }
        }
      });
    } else {
      developer.log(
          '❌ REALTIME DATA: API call failed with status code ${response.statusCode}');
      setState(() {
        counterValue = [];
        counterKey = [];
        isLoading = false;
      });
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
                  color: const Color.fromRGBO(42, 194, 188, 0.4470588235294118),
                  width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Shadow color
                  spreadRadius: 0, // Spread radius
                  blurRadius: 8, // Blur radius
                  offset: const Offset(10, 8), // Offset in x and y directions
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  counterKey[index].toString(),
                  style: const TextStyle(
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
