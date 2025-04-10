import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:isocial/view/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/LoginScreen.dart';

/*
  Activity name : splash activity
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool loginStatus = false;

  @override
  void initState() {
    // TODO: implement initState
    isLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: animatedIconShow(),
    );
  }

  //Show animated splash screen
  animatedIconShow() {
    return AnimatedSplashScreen(
        splash: Image.asset("assets/images/ihelpbd.png"),
        splashTransition: SplashTransition.scaleTransition,
        duration: 3000,
        // nextScreen: const LoginScreen());
        nextScreen: loginStatus ? DashBoardScreen() : LoginScreen());
  }

  Future isLogin() async {
    try {
      SharedPreferences ref = await SharedPreferences.getInstance();

      setState(() {
        loginStatus = ref.getBool("loginStatus")!;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        loginStatus = false;
      });
    }
  }
}
