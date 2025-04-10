import 'dart:math';

import 'package:flutter/material.dart';
import '/constants/constants.dart';


/*
  Component name : NotificationBellInfo
  Project name : iHelpBD CRM
  Auth : Eng. Sk Nayeem Ur Rahman
  Designation : Full Stack Software Developer
  Email : nayeemdeveloperbd@gmail.com
*/


class BellInfo extends StatelessWidget {
  const BellInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(appPadding),
          child: Stack(
            children: [
              Icon(Icons.notifications_on, size: 30, color: Colors.black54,),

              Positioned(
                left: 10,
                right: -5,
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: red,

                  ),
                    child: Center(child: Text(Random().nextInt(5).toString(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 12)))
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
