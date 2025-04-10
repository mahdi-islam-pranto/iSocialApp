import 'package:flutter/material.dart';
import '/constants/constants.dart';


/*
  Component name : AppTitle
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/

class AppTitleField extends StatelessWidget {
  const AppTitleField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Row(
        children: [
          Image.asset("assets/images/ilogo.png", height: 30, width: 30, color:  Color.fromRGBO(238, 75, 43, 1)),
          Text(" Social", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 2)),
        ],
      );
  }
}
