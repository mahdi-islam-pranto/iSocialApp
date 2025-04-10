import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        announcement: true,
        carPlay: true,
        criticalAlert: true,
        sound: true,
        provisional: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user permission granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("user permission provisinal granted");
    } else {
      print("user permission denied");
    }
  }
}
