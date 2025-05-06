import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:isocial/storage/sharedPrefs.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:rxdart/rxdart.dart';

// Define a top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Background message received: ${message.messageId}');
  // Don't need to show notification here as FCM will automatically display it
}

class NotificationServices {
  // Singleton pattern
  static final NotificationServices _instance =
      NotificationServices._internal();
  factory NotificationServices() => _instance;
  NotificationServices._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> _selectNotificationSubject =
      BehaviorSubject<String?>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Queue for storing notifications when offline
  final List<Map<String, dynamic>> _offlineNotificationQueue = [];
  bool _isInitialized = false;

  // Channel IDs
  final String _newTicketChannelId = 'new_ticket_channel';
  final String _newTicketChannelName = 'New Ticket Notifications';
  final String _newTicketChannelDescription = 'Notifications for new tickets';
  final String _fallbackChannelId = 'fallback_channel';
  final String _fallbackChannelName = 'Fallback Notifications';
  final String _fallbackChannelDescription =
      'Used when regular notifications fail';

  // Initialize notification services
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await requestNotificationPermission();

    // Get FCM token
    await getDeviceToken();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Set up foreground message handling
    _setupForegroundNotificationHandling();

    // Set up notification click handling
    _setupNotificationClickHandling();

    // Set up connectivity monitoring
    await _setupConnectivityMonitoring();

    // Load offline notification queue from storage
    await _loadOfflineNotificationQueue();

    // Add battery optimization exemption request for older devices
    await requestBatteryOptimizationExemption();

    _isInitialized = true;
    developer.log('🔔 Notification services initialized');
  }

  @pragma('vm:entry-point')
  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    bool permissionGranted = false;

    // For Android 13+ (API 33+), we need to request POST_NOTIFICATIONS permission
    if (Platform.isAndroid) {
      try {
        // Check Android version at runtime
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        developer.log('🔔 Android SDK version: $sdkInt');

        // Android 13 is API level 33
        if (sdkInt >= 33) {
          final status = await ph.Permission.notification.status;
          developer.log('🔔 Current notification permission status: $status');

          if (!status.isGranted) {
            developer.log('🔔 Requesting Android 13+ notification permission');
            final result = await ph.Permission.notification.request();
            developer
                .log('🔔 Android 13+ notification permission result: $result');
            permissionGranted = result.isGranted;
          } else {
            permissionGranted = true;
            developer.log('🔔 Notification permission already granted');
          }
        } else {
          // For older Android versions, permissions are granted at install time
          permissionGranted = true;
          developer.log(
              '🔔 Older Android version, permission granted at install time');
        }
      } catch (e) {
        developer.log('❌ Error checking Android version: $e');
        // Try to request permission anyway
        try {
          final result = await ph.Permission.notification.request();
          permissionGranted = result.isGranted;
          developer.log('🔔 Fallback notification permission result: $result');
        } catch (e) {
          developer.log('❌ Error requesting notification permission: $e');
        }
      }
    }

    // Firebase messaging permission request (works for iOS and older Android)
    try {
      NotificationSettings settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          announcement: true,
          carPlay: true,
          criticalAlert: true,
          sound: true,
          provisional: false); // Changed to false for more explicit permission

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        developer.log('🔔 User granted notification permission');
        permissionGranted = true;
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        developer.log('🔔 User granted provisional notification permission');
        permissionGranted = true;
      } else {
        developer.log('❌ User denied notification permission');
        permissionGranted = false;
      }
    } catch (e) {
      developer.log('❌ Error requesting Firebase notification permission: $e');
    }

    return permissionGranted;
  }

  // Get device token for FCM
  Future<String?> getDeviceToken() async {
    String? token = await _messaging.getToken();
    if (token != null) {
      try {
        // Save token to shared preferences
        await SharedPrefs.setString('fcm_token', token);
        developer.log('🔔 FCM Token: $token');
      } catch (e) {
        developer.log('❌ Error saving FCM token: $e');
        // Continue even if we can't save the token
      }
    }
    return token;
  }

  // Initialize local notifications
  @pragma('vm:entry-point')
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_stat_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        developer.log('🔔 Notification clicked: ${response.payload}');
        _selectNotificationSubject.add(response.payload);
      },
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  // Create notification channel for Android
  @pragma('vm:entry-point')
  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      // Regular channel
      final AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
        _newTicketChannelId,
        _newTicketChannelName,
        description: _newTicketChannelDescription,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      // Fallback channel with simpler settings for older devices
      final AndroidNotificationChannel fallbackChannel =
          AndroidNotificationChannel(
        _fallbackChannelId,
        _fallbackChannelName,
        description: _fallbackChannelDescription,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      final plugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (plugin != null) {
        await plugin.createNotificationChannel(mainChannel);
        await plugin.createNotificationChannel(fallbackChannel);
        developer.log('🔔 Android notification channels created');
      }
    }
  }

  @pragma('vm:entry-point')
  // Set up foreground notification handling
  void _setupForegroundNotificationHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('🔔 Foreground message received: ${message.messageId}');
      _showNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data),
      );
    });
  }

  // Set up notification click handling
  @pragma('vm:entry-point')
  void _setupNotificationClickHandling() {
    // Handle notification click when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('🔔 Background notification clicked: ${message.messageId}');
      // Navigate based on the notification data
      _handleNotificationClick(message.data);
    });

    // Handle notification click when app is in foreground
    _selectNotificationSubject.stream.listen((String? payload) {
      if (payload != null) {
        try {
          final Map<String, dynamic> data = jsonDecode(payload);
          _handleNotificationClick(data);
        } catch (e) {
          developer.log('❌ Error parsing notification payload: $e');
        }
      }
    });

    // Check if app was opened from a notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        developer.log('🔔 App opened from terminated state by notification');
        // Navigate based on the notification data
        _handleNotificationClick(message.data);
      }
    });
  }

  // Handle notification click
  @pragma('vm:entry-point')
  void _handleNotificationClick(Map<String, dynamic> data) {
    developer.log('🔔 Handling notification click with data: $data');

    // Check if notification is for a new ticket
    if (data['type'] == 'new_ticket') {
      // Navigate to ticket list page
      try {
        // Check if we're on the main thread
        if (WidgetsBinding.instance.isRootWidgetAttached) {
          Get.toNamed('/ticket_list');
        } else {
          // If we're not on the main thread, schedule navigation for later
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.toNamed('/ticket_list');
          });
        }
      } catch (e) {
        developer.log('❌ Error navigating to ticket list: $e');
        // Fallback navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.toNamed('/ticket_list');
        });
      }
    }
  }

  // Set up connectivity monitoring
  @pragma('vm:entry-point')
  Future<void> _setupConnectivityMonitoring() async {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      developer.log('🌐 Connectivity changed: $result');
      if (result != ConnectivityResult.none) {
        // We're back online, process offline notification queue
        _processOfflineNotificationQueue();
      }
    });
  }

  @pragma('vm:entry-point')
  // Show notification
  Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
    bool playSound = true,
  }) async {
    try {
      // Check connectivity before showing notification
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // We're offline, queue the notification
        _queueOfflineNotification(title, body, payload);
        return;
      }

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _newTicketChannelId,
        _newTicketChannelName,
        channelDescription: _newTicketChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: playSound,
        enableVibration: true,
        // icon: '@drawable/ic_stat_notification',
        // largeIcon: const DrawableResourceAndroidBitmap('@drawable/app_logo'),
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Generate a unique ID based on current time
      final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

      await _localNotifications.show(
        notificationId, // Use a more unique ID
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      developer.log('🔔 Notification shown: $title');
    } catch (e) {
      developer.log('❌ Error showing notification: $e');
      // Queue the notification for later if there was an error
      _queueOfflineNotification(title, body, payload);
    }
  }

  @pragma('vm:entry-point')

  // Show new ticket notification
  Future<void> showNewTicketNotification({
    required int count,
    String? ticketInfo,
  }) async {
    final String title = 'New Ticket${count > 1 ? 's' : ''}';
    final String body = count > 1
        ? 'You have $count tickets waiting'
        : 'You have a new ticket waiting';

    final Map<String, dynamic> data = {
      'type': 'new_ticket',
      'count': count.toString(),
      'info': ticketInfo,
    };

    try {
      await _showNotification(
        title: title,
        body: body,
        payload: jsonEncode(data),
      );
    } catch (e) {
      developer.log('❌ Regular notification failed, trying fallback: $e');
      // Try fallback method
      await showFallbackNotification(
        title: title,
        body: body,
        payload: jsonEncode(data),
      );
    }
  }

  // Add a fallback method for older devices
  @pragma('vm:entry-point')
  Future<void> showFallbackNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Simplified notification for older devices
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'fallback_channel',
        'Fallback Notifications',
        channelDescription: 'Used when regular notifications fail',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        // icon: '@drawable/ic_stat_notification', // Simple icon
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

      await _localNotifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      developer.log('🔔 Fallback notification shown: $title');
    } catch (e) {
      developer.log('❌ Error showing fallback notification: $e');
    }
  }

  // Queue notification for when device comes back online
  @pragma('vm:entry-point')
  void _queueOfflineNotification(String title, String body, String? payload) {
    developer.log('📶 Device is offline, queueing notification: $title');

    _offlineNotificationQueue.add({
      'title': title,
      'body': body,
      'payload': payload,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Save queue to storage
    _saveOfflineNotificationQueue();
  }

  // Process offline notification queue
  @pragma('vm:entry-point')
  Future<void> _processOfflineNotificationQueue() async {
    if (_offlineNotificationQueue.isEmpty) return;

    developer.log(
        '📶 Processing offline notification queue: ${_offlineNotificationQueue.length} items');

    // Sort by timestamp (oldest first)
    _offlineNotificationQueue
        .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    // Process each notification
    for (final notification in List.from(_offlineNotificationQueue)) {
      await _showNotification(
        title: notification['title'],
        body: notification['body'],
        payload: notification['payload'],
      );

      _offlineNotificationQueue.remove(notification);
    }

    // Save updated queue
    _saveOfflineNotificationQueue();
  }

  // Save offline notification queue to storage
  @pragma('vm:entry-point')
  Future<void> _saveOfflineNotificationQueue() async {
    try {
      final String queueJson = jsonEncode(_offlineNotificationQueue);
      await SharedPrefs.setString('offline_notification_queue', queueJson);
    } catch (e) {
      developer.log('❌ Error saving offline notification queue: $e');
    }
  }

  // Load offline notification queue from storage
  @pragma('vm:entry-point')
  Future<void> _loadOfflineNotificationQueue() async {
    try {
      final String? queueJson =
          SharedPrefs.getString('offline_notification_queue');
      if (queueJson != null && queueJson.isNotEmpty) {
        final List<dynamic> queue = jsonDecode(queueJson);
        _offlineNotificationQueue.clear();
        _offlineNotificationQueue.addAll(queue.cast<Map<String, dynamic>>());
        developer.log(
            '📶 Loaded offline notification queue: ${_offlineNotificationQueue.length} items');
      }
    } catch (e) {
      developer.log('❌ Error loading offline notification queue: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _selectNotificationSubject.close();
    _connectivitySubscription?.cancel();
  }

  @pragma('vm:entry-point')
  // Check if notification permissions are granted
  Future<bool> areNotificationPermissionsGranted() async {
    if (Platform.isIOS) {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } else if (Platform.isAndroid) {
      // For Android 13+, check notification permission
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return await ph.Permission.notification.isGranted;
      }
      // For older Android versions, permissions are granted at install time
      return true;
    }
    return false;
  }

  @pragma('vm:entry-point')
  // Call this method from your dashboard or wherever appropriate
  Future<bool> checkAndRequestNotificationPermissions(
      BuildContext context) async {
    // Check if context is still valid
    if (!context.mounted) return false;

    final hasPermissions = await areNotificationPermissionsGranted();
    developer.log('🔔 Current notification permission status: $hasPermissions');

    if (!hasPermissions) {
      // Check again if context is still valid after the async operation
      if (!context.mounted) return false;

      // Show a dialog explaining why notifications are important
      final shouldRequest = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Enable Notifications'),
              content: const Text(
                  'To receive important updates and alerts, please enable notifications for this app.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Not Now'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Enable'),
                ),
              ],
            ),
          ) ??
          false;

      if (shouldRequest && context.mounted) {
        return await requestNotificationPermission();
      }
      return false;
    }
    return true;
  }

  // Method to directly request permissions without confirmation dialog
  @pragma('vm:entry-point')
  Future<bool> requestNotificationPermissionsDirectly() async {
    developer.log('🔔 Directly requesting notification permissions');
    return await requestNotificationPermission();
  }

  // Add this method to request battery optimization exemption
  @pragma('vm:entry-point')
  Future<void> requestBatteryOptimizationExemption() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        // For Android 6.0+ (API level 23+)
        if (androidInfo.version.sdkInt >= 23) {
          final isIgnoringBatteryOptimizations =
              await ph.Permission.ignoreBatteryOptimizations.status;

          if (!isIgnoringBatteryOptimizations.isGranted) {
            await ph.Permission.ignoreBatteryOptimizations.request();
            developer.log('🔋 Requested battery optimization exemption');
          }
        }
      } catch (e) {
        developer.log('❌ Error requesting battery optimization exemption: $e');
      }
    }
  }
}
