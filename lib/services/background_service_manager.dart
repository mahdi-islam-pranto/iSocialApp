import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:isocial/notification_services.dart';
import 'package:isocial/storage/sharedPrefs.dart';
import 'package:workmanager/workmanager.dart';

// Define task names
const String fetchNewTicketsTask = 'fetchNewTicketsTask';

// Define callback for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      debugPrint('🔄 Background task started: $taskName');

      switch (taskName) {
        case fetchNewTicketsTask:
          await _checkForNewTickets();
          break;
        default:
          debugPrint('⚠️ Unknown task: $taskName');
      }

      return Future.value(true);
    } catch (e) {
      debugPrint('❌ Error in background task: $e');
      return Future.value(false);
    }
  });
}

// Initialize the background service
Future<void> initializeBackgroundService() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );

  // Register periodic task to check for new tickets
  await registerTicketCheckTask();
  debugPrint('🔄 Background service initialized');
}

// Register the periodic task to check for new tickets
Future<void> registerTicketCheckTask() async {
  // Cancel any existing tasks with the same name
  await Workmanager().cancelByUniqueName(fetchNewTicketsTask);

  // Register a new periodic task
  await Workmanager().registerPeriodicTask(
    fetchNewTicketsTask,
    fetchNewTicketsTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 1),
  );

  debugPrint('🔄 Ticket check task registered');
}

// Check for new tickets in the background
Future<void> _checkForNewTickets() async {
  debugPrint('🔄 Checking for new tickets in background');

  try {
    // Get stored ticket count
    final storedTicketCount = SharedPrefs.getInt('last_new_ticket_count') ?? 0;

    // Get current ticket count from API
    final currentTicketCount = await _fetchNewTicketCount();

    debugPrint('📊 Stored ticket count: $storedTicketCount');
    debugPrint('📊 Current ticket count: $currentTicketCount');

    // If current count is greater than stored count, show notification
    if (currentTicketCount > storedTicketCount) {
      final newTickets = currentTicketCount - storedTicketCount;
      debugPrint('🔔 New tickets detected: $newTickets');

      // Show notification
      final notificationServices = NotificationServices();
      await notificationServices.initialize();
      await notificationServices.showNewTicketNotification(
        count: newTickets,
        ticketInfo: 'You have $newTickets new ticket(s) waiting',
      );

      // Update stored count
      await SharedPrefs.setInt('last_new_ticket_count', currentTicketCount);
    }
  } catch (e) {
    debugPrint('❌ Error checking for new tickets: $e');
    // Don't update the stored count on error
  }
}

// Fetch the current new ticket count from the API
Future<int> _fetchNewTicketCount() async {
  try {
    // Get token and authorized_by from SharedPrefs
    final token = SharedPrefs.getString('token');
    final authorizedBy = SharedPrefs.getString('authorized_by');
    final username = SharedPrefs.getString('username');
    final role = SharedPrefs.getString('role');

    if (token == null ||
        authorizedBy == null ||
        username == null ||
        role == null) {
      debugPrint('❌ Missing required credentials');
      return 0;
    }

    // API URL
    const url =
        'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/realtime_count.php';

    // Request body
    final body = {
      'authorized_by': authorizedBy,
      'username': username,
      'role': role,
    };

    // Make the request with retry logic
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'content-type': 'application/json',
                'token': token,
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);

          if (jsonResponse['status'] == '200' && jsonResponse['data'] != null) {
            // Extract the new ticket count
            final data = jsonResponse['data'];

            // Check if we have the newTicket field
            if (data.containsKey('newTicket')) {
              final newTicketCount =
                  int.tryParse(data['newTicket'].toString()) ?? 0;
              debugPrint('📊 API returned new ticket count: $newTicketCount');
              return newTicketCount;
            } else {
              debugPrint('⚠️ API response missing newTicket field: $data');
              return 0;
            }
          } else {
            debugPrint(
                '⚠️ API returned error: ${jsonResponse['message'] ?? 'Unknown error'}');
            return 0;
          }
        } else {
          debugPrint(
              '⚠️ API request failed with status: ${response.statusCode}');
          retryCount++;
          await Future.delayed(Duration(seconds: 2 * retryCount));
        }
      } on SocketException catch (e) {
        debugPrint('⚠️ Network error (retry $retryCount): $e');
        retryCount++;
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on TimeoutException catch (e) {
        debugPrint('⚠️ Request timeout (retry $retryCount): $e');
        retryCount++;
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } catch (e) {
        debugPrint('❌ Unexpected error: $e');
        return 0;
      }
    }

    debugPrint('❌ Failed to fetch new ticket count after $maxRetries retries');
    return 0;
  } catch (e) {
    debugPrint('❌ Error in _fetchNewTicketCount: $e');
    return 0;
  }
}
