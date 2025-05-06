import 'dart:io';
import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:isocial/firebase_options.dart';
import 'package:isocial/storage/sharedPrefs.dart';
import 'package:provider/provider.dart';
import 'controllers/Controller.dart';
import 'SplashScreen.dart';
import 'notification_services.dart';

/*
  Activity name : Main activity
  Project name : iHelpBD CRM
  Auth : Eng. Sk Nayeem Ur Rahman, Mahdi Islam Pranto
  Designation : Full Stack Software Developer
  Email : nayeemdeveloperbd@gmail.com/ mahdiprantoblog@gmail.com
*/

//Launch activity
@override
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPrefs
  await SharedPrefs.init();

  // Initialize notification services with a slight delay to ensure Firebase is fully ready
  await Future.delayed(const Duration(milliseconds: 500));
  final notificationServices = NotificationServices();
  await notificationServices.initialize();

  // Test notification on app start (for debugging)
  if (Platform.isAndroid) {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 26) {
        // For older Android versions
        // Send a test notification after a delay
        Future.delayed(const Duration(seconds: 5), () {
          notificationServices.showFallbackNotification(
            title: "Test Notification",
            body: "This is a test notification for older devices",
          );
        });
      }
    } catch (e) {
      // Log the error
      developer.log('❌ Error checking Android version: $e');
    }
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => Controller(),
            )
          ],
          child: const SplashScreen(),
        ),
      ),
    );
  }
}
