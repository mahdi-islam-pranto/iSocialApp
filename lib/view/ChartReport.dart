import 'package:flutter/material.dart';
import 'package:isocial/view/LabelChart.dart';
import 'BarChart.dart';
import 'Dashboard.dart';

import '../constants/constants.dart';

/*
  Activity name : ChartReport Activity
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/

class ChartReport extends StatelessWidget {
   const ChartReport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // Page navigation bar
        appBar: AppBar(
          title: const Text("Chart"),

          centerTitle: true,

          // Back navigation button
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DashBoardScreen()));
              }),
        ),
        body: ListView(

            children: [
            //title padding
            const SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  "Label Report",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // label report section
            LabelChart(),


            const SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  "Count Report",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            //bar chart section
            BarChartShow(),

          ]
        ),
      ),
    );
  }
}
