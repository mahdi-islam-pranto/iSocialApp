import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';


//Ticket replay API

class NewReplyTicket{



  static ticketConversationNew() async {
    List conversationNewList = [];
    bool isLoading = false;
    bool isPostDisplay = false;
    String? reply;
    //Show progress dialog
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // Get user data from local device
    String token = sharedPreferences.getString("token").toString();
    String uniqueId = sharedPreferences.getString("uniqueId").toString();
    String dataType = sharedPreferences.getString("dataType").toString();
    String authorizedBy = sharedPreferences.getString("authorized_by").toString();
    String commentId = sharedPreferences.getString("commentId").toString();
    String pageId = sharedPreferences.getString("pageId").toString();


    print("comment id :${commentId}");
    print("data type :${dataType}");
    print("authorized_byyyyy :${authorizedBy}");
    print("unique id :${uniqueId}");
    print("page id :${pageId}");

    //   print("sender-type :${sendertype}");
    // new Api url
    String url = "https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/ticket_show_new.php";
    //Request API body
    Map<String, String> body = {
      "unique_id": uniqueId,
      "data_type": dataType,
      "authorized_by": authorizedBy,
      "comment_id": commentId,
      "page_id": pageId

    };

    HttpClient httpClient = HttpClient();

    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

    // content type
    request.headers.set('content-type', 'application/json');
    request.headers.set('token', token);

    request.add(utf8.encode(json.encode(body)));

    //Get response
    HttpClientResponse response = await request.close();
    reply = await response.transform(utf8.decoder).join();

    print("conversition Newdata : ${reply}");


    // Closed request
    httpClient.close();

    if (response.statusCode == 200) {

      final conversations = json.decode(reply!)["data"]['result'];
      print('conversiation::::::${conversations}');

      //
      // setState((){
      //   try {
      //
      //     conversationNewList = conversations;
      //     print('conversationNewListData:${conversationNewList}');
      //    //pageCommentAndAttachment = allData;
      //     isLoading = false;
      //     // Save sender_type in SharedPreferences
      //     String senderType = conversations.isNotEmpty
      //         ? conversations[0]['sender_type']
      //         : ''; // Assuming sender_type is available in the first conversation
      //     sharedPreferences.setString('sender_type', senderType);
      //
      //     String userId = conversations.isNotEmpty
      //         ? conversations[0]['user_id']
      //         : ''; // Assuming sender_type is available in the first conversation
      //     sharedPreferences.setString('user_id', userId);
      //     print("senderType : ${senderType}");
      //     print("userId : ${sharedPreferences.getString("user_id")}");
      //
      //   }catch(e){
      //
      //     isLoading = true;
      //   }
      // });
    } else {
      conversationNewList = [];
      isLoading = false;
    }

  }

}