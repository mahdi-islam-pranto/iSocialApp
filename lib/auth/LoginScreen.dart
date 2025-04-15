import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isocial/api/login_api.dart';
import 'package:isocial/data/localData.dart';
import 'package:isocial/view/CustomProgress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../constant.dart';
import '../view/Dashboard.dart';

/*
  Activity name : Login activity
  Project name : iHelpBD CRM
  Auth : Eng. Sk Nayeem Ur Rahmab
  Designation : Full Stack Software Developer
  Email : nayeemdevoloperbd@gmail.com
*/

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _loginPageState createState() => _loginPageState();
}

// ignore: camel_case_types
class _loginPageState extends State<LoginScreen> {
  late String email, password;

  final emailKey = GlobalKey<FormState>();
  final passwordKey = GlobalKey<FormState>();

  bool isProgressShow = false;

  late SimpleFontelicoProgressDialog dialog;

  // final emailText = TextEditingController();
  // final passwordText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: SafeArea(
          child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xfff2f3f7),
        body: Stack(
          children: <Widget>[
            // Box
            Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: MediaQuery.of(context).size.width,
              child: Container(
                //Box container

                decoration: const BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(70),
                    bottomRight: Radius.circular(70),
                  ),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildLogo(),
                _buildContainer(),
                _buildInventor(),
              ],
            )
          ],
        ),
      )),
    );
  }

  // App name like CRM
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'iSocial',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 30,
                      ),
                    ),
                  ],
                ),
                _buildEmailRow(),
                _buildPasswordRow(),
                _buildForgetPassword(),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Email field
  Widget _buildEmailRow() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Form(
        key: emailKey,
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required.';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              email = value;
            });
          },
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email, color: mainColor),
              labelText: 'E-mail'),
        ),
      ),
    );
  }

  // Password field
  Widget _buildPasswordRow() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Form(
        key: passwordKey,
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required.';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              password = value;
            });
          },
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock, color: mainColor),
              labelText: 'Password'),
        ),
      ),
    );
  }

  Widget _buildForgetPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextButton(
          onPressed: () {},
          child: const Text("Forgot Password?"),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height / 22),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: const EdgeInsets.only(bottom: 20),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              // //Dashboard

              // check input field is valid or not
              if (emailKey.currentState!.validate() &&
                  passwordKey.currentState!.validate()) {
                login();

                // LoginAPI loginApi = LoginAPI(context);
                // loginApi.login(email,password);
              }
            },
            child: Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height / 40,
              ),
            ),
          ),
        ),
      ],
    );
  }

  //
  // Widget _buildSignUpBtn()  {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       Padding(padding: EdgeInsets.zero,
  //         child: TextButton(
  //           onPressed: () {},
  //           child: RichText(
  //             text: TextSpan(children: [
  //               TextSpan(
  //                 text: 'Dont have an account? ',
  //                 style: TextStyle(
  //                   color: Colors.black,
  //                   fontSize: MediaQuery.of(context).size.height / 50,
  //                   fontWeight: FontWeight.w300,
  //                 ),
  //               ),
  //               TextSpan(
  //                 text: 'Sign Up',
  //                 style: TextStyle(
  //                   color: mainColor,
  //                   fontSize: MediaQuery.of(context).size.height / 45,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               )
  //             ]),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildInventor() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: TextButton(
            onPressed: () {},
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Developed by ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: "iHelpBD",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildSocialBtnRow() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       GestureDetector(
  //         onTap: () {},
  //         child: Container(
  //           height: 60,
  //           width: 60,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: mainColor,
  //             boxShadow: [
  //               BoxShadow(
  //                   color: Colors.black26,
  //                   offset: Offset(0, 2),
  //                   blurRadius: 6.0)
  //             ],
  //           ),
  //           child: Icon(
  //             FontAwesomeIcons.google,
  //             color: Colors.white,
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }

  // Widget _buildOrRow() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       Container(
  //         margin: const EdgeInsets.only(bottom: 5),
  //         child: const Text(
  //           '- OR -',
  //           style: TextStyle(
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }

// Back button alert
  Future<bool> onBackPressed() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit?.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  // Login method
  Future<void> login() async {
    CustomProgress customProgress = CustomProgress(context);
    try {
      customProgress.showDialog(
          "Please wait", SimpleFontelicoProgressDialogType.spinner);

      // Api url
      String url =
          'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/login.php';

      //Authentication
      //  Map<String, String> auth = {"email": email, "password": password};

      // device id
      const _androidIdPlugin = AndroidId();

      final String? androidId = await _androidIdPlugin.getId();
      print("Andriod Id:> ${androidId}");

      Map<String, dynamic> body = {
        "email": email,
        "password": password,
        "device_id": androidId
      };

      HttpClient httpClient = HttpClient();

      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

      // content type
      request.headers.set('Content-Type', 'application/json');

      request.add(utf8.encode(json.encode(body)));

      //Get response
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();

      // Closed request
      httpClient.close();

      final data = jsonDecode(reply);

      print("data of : ${data}");

      //Check response code
      if (response.statusCode == 200) {
        // Parse jason data

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        // Check token
        if (data['data']['token'] != null) {
          //Store token in local device
          sharedPreferences.setString("token", data['data']['token']);
          // Store login status
          sharedPreferences.setBool("loginStatus", true);
          //Store username
          sharedPreferences.setString(
              "username", data['data']['username'].toString());

          /// username
          print(data['data']['username']);

          /// token
          print(data['data']['token']);

          /// authorized_by
          print(data['data']['authorized_by']);

          ///role
          print(data['data']['role']);

          //Store email
          sharedPreferences.setString("email", email);
          //authorized_by
          sharedPreferences.setString(
              "authorized_by", data['data']['authorized_by'].toString());
          //role
          sharedPreferences.setString("role", data['data']['role'].toString());
          //token_expire_date
          sharedPreferences.setString("token_expire_date",
              data['data']['token_expire_date'].toString());

          // Set real time counter dashboard height
          if (data['data']['role'] == "admin") {
            //admin
            LocalData.dashBoardRealTimeCounterHeight = 375;
          } else {
            //User
            LocalData.dashBoardRealTimeCounterHeight = 260;
          }

          //Hide progress
          customProgress.hideDialog();

          //Dashboard
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const DashBoardScreen()));
        } else {
          //Hide progress
          customProgress.hideDialog();

          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Token Error"),
              content: const Text('Invalid token.',
                  style: TextStyle(color: Colors.red)),
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
      } else {
        //Hide progress
        customProgress.hideDialog();

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              "Login Error",
              style: TextStyle(color: Colors.yellow),
            ),
            content: const Text("Invalid email or password.",
                style: TextStyle(color: Colors.red)),
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

        //Hide progress
        // customProgress.hideDialog();
      }
    } catch (e) {
      //Hide progress
      customProgress.hideDialog();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "Login Error,",
            style: TextStyle(color: Colors.blue),
          ),
          content: Text("Invalid email or password.",
              style: const TextStyle(color: Colors.red)),
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
}
