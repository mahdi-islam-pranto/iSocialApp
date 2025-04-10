// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
// import '../api/login_api.dart';
// import '../constant.dart';


   /// New isocial client app (ghorer cutir)


//
// /*
//   Activity name : UserLoginScreen
//   Project name : iSalesCRM Mobile App
//   Developer : Eng. Sk Nayeem Ur Rahman
//   Designation : Senior Mobile App Developer at iHelpBD Dhaka, Bangladesh.
//   Email : nayeemdeveloperbd@gmail.com
// */
//
// class UserLoginScreen extends StatefulWidget{
//   const UserLoginScreen({super.key});
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _loginPageState createState() => _loginPageState();
// }
// // ignore: camel_case_types
// class _loginPageState extends State<UserLoginScreen> {
//
//   late String email, password;
//
//   final emailKey = GlobalKey<FormState>();
//   final passwordKey = GlobalKey<FormState>();
//
//   late SimpleFontelicoProgressDialog dialog;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return WillPopScope(
//       onWillPop: onBackPressed,
//       child: SafeArea(
//           child: Scaffold(
//             resizeToAvoidBottomInset: false,
//             backgroundColor: const Color(0xfff2f3f7),
//             body: Stack(
//               children: <Widget>[
//
//                 // Box
//                 SizedBox(
//                   height: MediaQuery
//                       .of(context)
//                       .size
//                       .height * 0.65,
//                   width: MediaQuery
//                       .of(context)
//                       .size
//                       .width,
//                   child: Container(
//                     //Box container
//
//                     decoration: const BoxDecoration(
//
//                       color: mainColor,
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(70),
//                         bottomRight: Radius.circular(70),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     _buildLogo(),
//                     _buildContainer(),
//                     _buildInventor(),
//                   ],
//                 )
//
//
//               ],
//             ),
//           )
//       ),
//     );
//   }
//
//   // App name like CRM
//   Widget _buildLogo() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Text('iCRM',
//           style: TextStyle(
//             fontSize: MediaQuery
//                 .of(context)
//                 .size
//                 .height / 25,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         )
//       ],
//     );
//   }
//
//
//   Widget _buildContainer() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         ClipRRect(
//           borderRadius: const BorderRadius.all(
//             Radius.circular(20),
//
//           ),
//
//           child: Container(
//             height: MediaQuery
//                 .of(context)
//                 .size
//                 .height * 0.55,
//             width: MediaQuery
//                 .of(context)
//                 .size
//                 .width * 0.8,
//             decoration: const BoxDecoration(
//               color: Colors.white,
//             ),
//
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Text("Login",
//                       style: TextStyle(
//                         fontSize: MediaQuery
//                             .of(context)
//                             .size
//                             .height / 30,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 _buildEmailRow(),
//                 _buildPasswordRow(),
//                 _buildForgetPassword(),
//                 _buildLoginButton(),
//
//               ],
//             ),
//
//           ),
//
//         ),
//       ],
//     );
//   }
//
//   // Email field
//   Widget _buildEmailRow() {
//     return Padding
//       (padding: const EdgeInsets.all(8),
//       child: Form(
//         key: emailKey,
//         child: TextFormField(
//
//           keyboardType: TextInputType.emailAddress,
//
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Email is required.';
//             }
//             return null;
//           },
//
//           onChanged: (value) {
//             setState(() {
//               email = value;
//             });
//           },
//
//           decoration: const InputDecoration(
//               prefixIcon: Icon(
//                   Icons.email,
//                   color: mainColor
//               ),
//
//               labelText: 'E-mail'),
//
//         ),
//       ),
//     );
//   }
//
//   // Password field
//   Widget _buildPasswordRow() {
//     return Padding
//       (padding: const EdgeInsets.all(8),
//       child: Form(
//
//         key: passwordKey,
//
//         child: TextFormField(
//           keyboardType: TextInputType.text,
//           obscureText: true,
//
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Password is required.';
//             }
//             return null;
//           },
//
//           onChanged: (value) {
//             setState(() {
//               password = value;
//             });
//           },
//
//           decoration: const InputDecoration(
//               prefixIcon: Icon(
//                   Icons.lock,
//                   color: mainColor
//               ),
//
//               labelText: 'Password'),
//
//         ),
//       ),
//     );
//   }
//
//   Widget _buildForgetPassword() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         TextButton(onPressed: () {}, child: const Text("Forgot Password?",style: TextStyle(color: Color.fromRGBO(3, 197, 160, 1)),),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoginButton() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Container(
//           height: 1.4 * (MediaQuery
//               .of(context)
//               .size
//               .height / 22),
//           width: 5 * (MediaQuery
//               .of(context)
//               .size
//               .width / 10),
//           margin: const EdgeInsets.only(bottom: 20),
//           child: ElevatedButton(
//             style: ButtonStyle(
//                 backgroundColor:
//                 MaterialStateProperty.all(Color.fromRGBO(3, 197, 160, 1))),
//             onPressed: () {
//
//               //await FlutterOverlayWindow.showOverlay();
//
//               //Dashboard
//               // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const DashboardScreen()));
//
//
//               // check input field is valid or not
//               if (emailKey.currentState!.validate() &&
//                   passwordKey.currentState!.validate()) {
//
//                 ///call login api
//
//                 LoginAPI loginApi = LoginAPI(context);
//                 loginApi.login(email,password);
//               }
//             }
//             ,
//             child: Text("Login", style: TextStyle(
//               color: Colors.white,
//               letterSpacing: 1.5,
//               fontSize: MediaQuery
//                   .of(context)
//                   .size
//                   .height / 40,
//             ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInventor() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Padding(
//           padding: EdgeInsets.only(top: 40),
//           child: TextButton(
//             onPressed: (){
//
//               var url = Uri.parse("https://ihelpbd.com");
//              // launchUrl(url);
//
//             },
//             child: RichText(
//               text: TextSpan(children: [
//                 TextSpan(
//                   text: 'Developed by ',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: MediaQuery
//                         .of(context)
//                         .size
//                         .height / 40,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 TextSpan(
//                   text: "iHelpBD",
//                   style: TextStyle(
//                     color: mainColor,
//                     fontSize: MediaQuery
//                         .of(context)
//                         .size
//                         .height / 40,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 )
//               ]),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Future<bool> onBackPressed() async {
//     return (await showDialog(
//       context: context,
//       builder: (context) =>
//           AlertDialog(
//             title: Text('Are you sure?'),
//             content: const Text('Do you want to exit?.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text('No'),
//               ),
//               TextButton(
//                 onPressed: () => SystemNavigator.pop(),
//                 child: const Text('Yes'),
//               ),
//             ],
//           ),
//     )) ??
//         false;
//   }
// }
