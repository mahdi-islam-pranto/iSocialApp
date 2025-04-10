import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:isocial/view/AllPost.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../navigationservice/NavigationService.dart';

class PostModel {
  final String id;
  final String post_id;
  final String page_name;
  final String status;
  final String created_at;

  PostModel(
      this.id, this.post_id, this.page_name, this.status, this.created_at);

  DataRow getRow(
    SelectedCallBack callback,
    List<String> selectedIds,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(id.toString())),
        DataCell(Text(page_name)),
        DataCell(Text(status)),
        DataCell(Text(created_at)),
        DataCell(IconButton(icon: Icon(Icons.remove_red_eye, color: Colors.grey,),

            onPressed: () {

              // Create context og AllPost page
              BuildContext? context = NavigationService.navigatorKey.currentContext;

              // Post dialog popup
              showPost(context!, post_id);


            })),
      ],
      onSelectChanged: (newState) {
        callback(id.toString(), newState ?? false);
      },
      selected: selectedIds.contains(id.toString()),
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      json['id'] as String,
      json['post_id'] as String,
      json['page_name'] as String,
      json['status'] as String,
      json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "post_id": post_id,
      'page_name': page_name,
      'status': status,
      'created_at': created_at,
    };
  }

  void showPost(BuildContext context, String postId) async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? token = sharedPreferences.getString("token");
    String? authorizedBy = sharedPreferences.getString("authorized_by");



    // Api url
    String url = 'https://omni.ihelpbd.com/ihelpbd_social/api/v1/post_view.php';

    //Request API body
    Map<String, String> body =
    {
      "authorized_by": authorizedBy.toString(),
      "post_id": post_id,

    };

    HttpClient httpClient = HttpClient();

    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

    // content type
    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token.toString());

    request.add(utf8.encode(json.encode(body)));

    //Get response
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();

    print(reply);


    final data = jsonDecode(reply);

    // Closed request
    httpClient.close();

    try {
      if (response.statusCode == 200) {

        AwesomeDialog(

          showCloseIcon: true,
          animType: AnimType.scale,
          titleTextStyle: TextStyle(color: Colors.black),
          context: context,

          customHeader: Text("Post", style: TextStyle(fontSize: 20),),

          //dialogType: DialogType.info,
          body: Container(

            height: MediaQuery
                .of(context)
                .size
                .height * .6,

            margin: EdgeInsets.all(10),

            child: ListView(

              children: [

                //Comments counter
                Text("  View Post-Count: ${data['data']['comment_count']}",
                    style: TextStyle(fontSize: 15, color: Colors.black)),

                Container(
                  margin: const EdgeInsets.all(10),

                  //Post message
                  child: Text(data['data']['message'].toString(),
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                ),

                SizedBox(
                  height: 15,
                ),

                //Post image

                Image.network(
                    "https://www.techandteen.com/wp-content/uploads/2020/05/realme-c3-1280x720.jpg")
              ],
            ),
          ),
        ).show();
      }
      else {
        await showDialog(

          context: context,

          builder: (context) =>

              AlertDialog(

                title: Text("API Error"),

                content: Text(data["data"].toString(),
                    style: TextStyle(color: Colors.black)),

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
    }catch(e){

      //Exception handling

      await showDialog(

        context: context,

        builder: (context) =>

            AlertDialog(

              title: Text("Error"),

              content: Text(e.toString(),
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


  }
}
