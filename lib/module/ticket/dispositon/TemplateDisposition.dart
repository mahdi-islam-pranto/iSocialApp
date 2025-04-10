import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DispositonController.dart';

class TemplateDisposition extends StatefulWidget {
  const TemplateDisposition({Key? key}) : super(key: key);

  @override
  State<TemplateDisposition> createState() => _TemplateDispositionState();
}

class _TemplateDispositionState extends State<TemplateDisposition> {
  List<String> templateDisTitle = [];
  List<String> templateDisMessage = [];
  bool isLoading = false;
  String dropDownValue = " --Template--";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchTemplateDispositionData();
  }

  void fetchTemplateDispositionData() async {
    setState(() {
      isLoading = true;
    });

    //Show progress dialog
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    //Get user data from local device
    String token = sharedPreferences.getString("token").toString();
    String authorizedBy =
        sharedPreferences.getString("authorized_by").toString();

    // Api url
    String url = 'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/template.php';

    //Request API body
    Map<String, String> body = {"authorized_by": authorizedBy};

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

    if (response.statusCode == 200) {
      final items = json.decode(reply)["data"];

      setState(() {
        try {
          for (int index = 0; index < items.length; index++) {
            templateDisTitle.add(items[index]["title"].toString());

            templateDisMessage.add(items[index]["massage"].toString());
          }

          isLoading = false;

        } catch (e) {
          isLoading = true;
        }
      });
    } else {

      templateDisTitle = [];
      templateDisMessage = [];
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return getTemplateDisposition();
  }

  Widget getTemplateDisposition() {

    if (templateDisTitle.contains(null) || isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    }


    // List of items in our dropdown menu
    var template = [' --Template--'];

    //Add template title
    template.addAll(templateDisTitle);


    return Container(
      height: 30.h,
      color: Colors.white54,
      child: Container(
        padding: EdgeInsets.only(left: 10,right: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey,),
          borderRadius: BorderRadius.circular(15),
        ),
        child: DropdownButton(
            isExpanded: true,
            underline:SizedBox(),
            // Initial Value
            value: dropDownValue,
            icon: const Icon(Icons.keyboard_arrow_down,color: Colors.black,),

            // Array list of items
            items: template.map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(
                  items,
                  style: TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (dynamic newValue) {
              setState(() {

                // Get message from template message
                DispositionController.dispositionController.text = templateDisMessage[templateDisTitle.indexOf(newValue)];
                dropDownValue = newValue.toString();

              });
            }),
      ),
    );
  }
}
