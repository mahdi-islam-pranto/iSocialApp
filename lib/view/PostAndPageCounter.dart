import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';


/*
  Activity name : DashboardPostCounter API handler
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/



class PostAndPageCounter extends StatefulWidget {
  const PostAndPageCounter({Key? key}) : super(key: key);

  @override
  State<PostAndPageCounter> createState() => _PostAndPageCounterState();
}

class _PostAndPageCounterState extends State<PostAndPageCounter> {

  List postPageCounter = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return getBody();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    fetchPostPageCounterData();
  }
  

  void fetchPostPageCounterData() async {

    setState(() {
      isLoading = true;
    });

    //Show progress dialog
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    //Get user data from local device
    String token = sharedPreferences.getString("token").toString();
    String authorized_by = sharedPreferences.getString("authorized_by").toString();

    // Api url
    String url = 'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/dash_count.php';

    //Request API body
    Map<String, String> body = {
      "authorized_by": authorized_by,
    };

    HttpClient httpClient = HttpClient();

    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

    // content type
    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token);

    request.add(utf8.encode(json.encode(body)));

    //Get response
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();

    // Closed request
    httpClient.close();


    // print(reply);

    // print(response.body);
    if (response.statusCode == 200) {

      setState(() {
        try {

          // Set dashboard counter data
          postPageCounter = [json.decode(reply)["data"]['pageCount'], json.decode(reply)["data"]['postCount']];
          isLoading = false;

        }catch(e){
          isLoading = true;
        }
      });
    } else {
      postPageCounter = [];
      isLoading = false;
    }

  }

  Widget getBody() {

    try {


      if (postPageCounter.contains(null) || postPageCounter.length < 0 || isLoading) {
        return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ));
      }
      


      return Center(
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 100,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10),

          // disable scrollable
          primary: false,

          children: [

            // Total Pages Counter
            Card(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: appPadding, vertical: appPadding / 2,),

                decoration: BoxDecoration(color: secondaryColor,
                    borderRadius: BorderRadius.circular(15),
                  border: Border(
                    left: BorderSide(
                      color: Colors
                          .blue, // Set the color you want for the left border
                      width:
                      5.0.w, // Set the width of the left border
                    ),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          postPageCounter[0].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(appPadding / 2),
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                              color: Colors.blue!.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: SvgPicture.asset(
                            "assets/icons/Pages.svg",
                            color: Colors.blue,
                          ),
                        )
                      ],
                    ),
                    Text("Total Pages",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Total Post Counter
            Card(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: appPadding, vertical: appPadding / 2,),

                decoration: BoxDecoration(color: secondaryColor,
                    border: Border(
                      left: BorderSide(
                        color: Colors
                            .purple, // Set the color you want for the left border
                        width:
                        5.0.w, // Set the width of the left border
                      ),
                    ),
                    borderRadius: BorderRadius.circular(15)),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          postPageCounter[1].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(appPadding / 2),
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                              color: Colors.purple!.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: SvgPicture.asset(
                            "assets/icons/Statistics.svg",
                            color: Colors.purple,
                          ),
                        )
                      ],
                    ),
                    Text("Total Post",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),


          ],
        ),
      );
    } catch (e) {
      print(e.toString());
      return const Center(child: Text("Loading failed"));
    }
  }
}
