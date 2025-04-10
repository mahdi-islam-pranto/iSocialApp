import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../static-variable/StaticVariables.dart';
import 'DispositonController.dart';

/*
  Activity name : Label disposition
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/

class LabelDisposition extends StatefulWidget {
  const LabelDisposition({Key? key}) : super(key: key);

  @override
  State<LabelDisposition> createState() => _LabelDispositionState();
}

class _LabelDispositionState extends State<LabelDisposition> {
  List<String> labelDisposition = [];
  String? labelDropDownValue = " --Label--";

  bool labelDispositionIsLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchLabelDispositionData();
  }

  void fetchLabelDispositionData() async {
    setState(() {
      labelDispositionIsLoading = true;
    });

    //Show progress dialog
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    //Get user data from local device
    String token = sharedPreferences.getString("token").toString();
    String authorizedBy =
        sharedPreferences.getString("authorized_by").toString();

    // Api url
    String url = 'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/label.php';

    //Request API body
    Map<String, dynamic> body = {
      "authorized_by": authorizedBy,
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
    if (response.statusCode == 200) {
      var items = json.decode(reply)["data"];
      setState(() {
        try {
          labelDisposition = [
            items[0],
            items[1],
            items[2],
          ];
          labelDispositionIsLoading = false;
        } catch (e) {
          labelDispositionIsLoading = true;
        }
      });
    } else {
      labelDisposition = [];
      labelDispositionIsLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return getLabelDisposition();
  }

  Widget getLabelDisposition() {
    if (labelDisposition.contains(null) || labelDispositionIsLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    }

    // List of items in our dropdown menu
    var template = [" --Label--"];

    //Add template title
    template.addAll(labelDisposition);

    return DropdownButton(
        isExpanded: true,

        // Initial Value
        value: labelDropDownValue,
        icon: const Icon(Icons.keyboard_arrow_down),

        // Array list of items
        items: template.map((dynamic items) {
          return DropdownMenuItem(
            value: items,
            child: Text(
              items,
              style: const TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
        onChanged: (dynamic newValue) {
          setState(() {
            labelDropDownValue = newValue;
            DispositionController.labelId = labelDropDownValue.toString();

            // StaticVariable.LabelDisposition = true;
          });
        });
  }
}
