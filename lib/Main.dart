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
