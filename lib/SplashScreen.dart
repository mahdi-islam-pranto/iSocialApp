import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isocial/view/Dashboard.dart';
import 'package:isocial/storage/sharedPrefs.dart';
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
    super.initState();
    // Check login status and navigate after a short delay
    isLogin().then((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.off(
            () => loginStatus ? const DashBoardScreen() : const LoginScreen());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/ihelpbd.png",
          width: 200,
          height: 200,
        ),
      ),
    );
  }

  Future<void> isLogin() async {
    try {
      // Use the SharedPrefs utility class
      final loginValue = SharedPrefs.getBool("loginStatus");
      setState(() {
        loginStatus = loginValue ?? false;
      });
    } catch (e) {
      debugPrint("Login check error: ${e.toString()}");
      setState(() {
        loginStatus = false;
      });
    }
  }
}
