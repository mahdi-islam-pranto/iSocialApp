import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isocial/domain/service/api_service.dart';
import 'package:isocial/domain/service/default_response.dart';
import 'package:isocial/storage/sharedPrefs.dart';
import 'package:isocial/utilities/message/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api_url.dart';
import '../dispositon/DispositonController.dart';
import '../model/ticket_conversation_list.response.dart';
import '../model/ticket_list_response.dart';
import 'package:http/http.dart' as http;

class TicketController extends GetxController {
  RxList<ConversationUIModel> conversationList = <ConversationUIModel>[].obs;
  RxString reply = "".obs;
  RxBool loading = true.obs;
  RxBool uploadingAttachment =
      false.obs; // For attachment upload loading indicator

  @override
  void onInit() {
    loadSavedConversations();
    getTicketConversation();
    super.onInit();
  }

  Future<void> getTicketConversation() async {
    Map<String, dynamic> body = {
      "unique_id": SharedPrefs.getString("uniqueId"),
      "data_type": SharedPrefs.getString("dataType"),
      "authorized_by": SharedPrefs.getString("authorized_by"),
      "comment_id": SharedPrefs.getString("commentId"),
      "page_id": SharedPrefs.getString("pageId")
    };

    Map<String, String> header = {
      "token": SharedPrefs.getString("token") ?? ""
    };

    try {
      DefaultResponse defaultResponse = await ApiService.post(
          url: ApiUrls.conversationList, body: body, header: header);

      if (defaultResponse.success) {
        TicketConversationListResponseModel conversationListResponseModel =
            TicketConversationListResponseModel.fromJson(
                defaultResponse.response);

        List<ConversationUIModel> newConversationList =
            conversationListResponseModel.data?.conversationList ?? [];

        for (var conversation in newConversationList) {
          // Determine attachment type based on the file extension
          if (conversation.attachmentUrl != null) {
            String fileExtension =
                conversation.attachmentUrl!.split('.').last.toLowerCase();
            if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
              conversation.attachmentType = 'image';
            } else {
              conversation.attachmentType = 'file';
            }
          }
        }

        conversationList.value = newConversationList;
      } else {
        showBasicFailedSnackBar(message: defaultResponse.response['message']);
      }

      conversationList.refresh();
      conversationBoxScrollToBottom();

      log("Auto loading is working ::::::");
    } finally {
      loading.value = false;
    }
  }

  RxList<TicketListUIModel> ticketList = <TicketListUIModel>[].obs;
  RxBool isLoading = false.obs;

// fetch ticket list
  void fetchTicketList() async {
    Map<String, dynamic> body = {
      "authorized_by": SharedPrefs.getString("authorized_by"),
      "username": SharedPrefs.getString("username"),
      // "role": SharedPrefs.getString("role"),
      "role": "user"
    };

    Map<String, dynamic> header = {
      "token": SharedPrefs.getString("token"),
    };

    log("Fetching ticket list with body: $body");
    log("Headers: $header");

    try {
      isLoading.value = true;
      DefaultResponse defaultResponse = await ApiService.post(
          url: ApiUrls.ticketList, body: body, header: header);

      log("Ticket list API response success: ${defaultResponse.success}");
      if (defaultResponse.success) {
        log("Response data: ${defaultResponse.response}");

        try {
          TicketListResponseModel ticketListResponseModel =
              TicketListResponseModel.fromJson(defaultResponse.response);

          log("Parsed ticket list: ${ticketListResponseModel.ticketList?.length ?? 0} items");
          ticketList.value = ticketListResponseModel.ticketList ?? [];
          log("Ticket list updated successfully");
        } catch (e) {
          log("Error parsing ticket list response: $e");
          showBasicFailedSnackBar(message: "Error parsing data: $e");
        }
      } else {
        log("API call failed: ${defaultResponse.response['message']}");
        showBasicFailedSnackBar(message: defaultResponse.response['message']);
      }
    } catch (e, stackTrace) {
      log("Exception in fetchTicketList: $e");
      log("Stack trace: $stackTrace");
      showBasicFailedSnackBar(message: "Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void sendReplay() async {
    try {
      Map<String, dynamic> body = {
        "authorized_by": SharedPrefs.getString("authorized_by"),
        "message_data": DispositionController.messageData,
        "replay_data_type": SharedPrefs.getString("dataType"),
        "replay_id": SharedPrefs.getString("commentId"),
        "replay_name": DispositionController.replayName,
        "replay_page_id": SharedPrefs.getString("pageId"),
        "ticket_status": DispositionController.ticketStatus,
        "disposition_type": DispositionController.dispositionType,
        "disposition_cat": DispositionController.dispositionCat,
        "disposition_sub_cat": DispositionController.dispositionSubCat,
        "label_id": DispositionController.labelId,
        "username": SharedPrefs.getString("username")
      };

      Map<String, String> header = {
        "token": SharedPrefs.getString("token") ?? ""
      };

      DefaultResponse defaultResponse = await ApiService.post(
          url: ApiUrls.ticketReplay, body: body, header: header);

      if (defaultResponse.success) {
        ConversationUIModel conversationUIModel = ConversationUIModel(
          userName: SharedPrefs.getString("username"),
          message: DispositionController.messageData,
          commentCreatedTime: CommentCreatedTime(
              date: DateFormat('dd MMM, yyyy').format(DateTime.now()),
              time: DateFormat('hh:mm a').format(DateTime.now())),
          senderType: "owner",
        );
        conversationList.add(conversationUIModel);
        conversationList.refresh();
        conversationBoxScrollToBottom();
        DispositionController.clearData();
      } else {
        DispositionController.dispositionController.text =
            DispositionController.messageData.toString();
        DispositionController.messageData = "";
        showBasicFailedSnackBar(message: defaultResponse.response['message']);
      }
    } catch (e, tr) {
      showBasicFailedSnackBar(message: e.toString());
      log("Error -> $e");
      log("Track -> $tr");
    }
  }

  //  attachment

  void attachmentReplayController(File file) async {
    log("attachmentReplayController called with file: ${file.path}");
    try {
      // Show loading indicator
      uploadingAttachment.value = true;

      String fileName = file.path.split('/').last;
      log("Uploading file: $fileName");

      // Now send the file to the server with updated parameters based on Postman screenshot
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiUrls.attachmentReplyUrl),
      );

      // Get token from SharedPreferences
      String? token = SharedPrefs.getString("token");
      if (token == null || token.isEmpty) {
        log("ERROR: Token is null or empty!");
        showBasicFailedSnackBar(
            message: "Authentication token is missing. Please log in again.");
        uploadingAttachment.value = false;
        return;
      }

      // Add token to request headers
      request.headers['token'] = token;
      // Don't set content-type for multipart/form-data requests, it will be set automatically
      log("Request headers: ${request.headers}");

      // Add necessary fields based on the new API requirements
      request.fields['authorized_by'] =
          SharedPrefs.getString("authorized_by") ?? "ihelp20240123idev";
      request.fields['recipient_id'] = SharedPrefs.getString("commentId") ?? "";
      request.fields['page_id'] = SharedPrefs.getString("pageId") ?? "";
      request.fields['replay_name'] = DispositionController.replayName;
      request.fields['unique_id'] = SharedPrefs.getString("uniqueId") ?? "";
      request.fields['ticket_status'] = DispositionController.ticketStatus;

      // Adding the file with the correct field name 'media_file' instead of 'file'
      request.files
          .add(await http.MultipartFile.fromPath('media_file', file.path));
      log("File added to request as media_file: ${file.path}");
      log("Request fields: ${request.fields}");

      // Send the request
      var response = await request.send();

      log('Response status: ${response.statusCode}');

      // This is now handled by the _saveConversationList method

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        log('Response data: $responseData');

        try {
          var jsonResponse = json.decode(responseData);

          // Check if the response has the expected structure
          if (jsonResponse.containsKey('status') &&
              jsonResponse['status'] == "200") {
            // Check if data field exists and has the expected structure
            if (jsonResponse.containsKey('data')) {
              var data = jsonResponse['data'];

              // Handle different response formats
              if (data is Map &&
                  data.containsKey('status') &&
                  data['status'] == "success") {
                log('File uploaded successfully');
              } else if (data is String && data.contains("success")) {
                log('File uploaded successfully (string response)');
              } else {
                log('File uploaded with response: $data');
              }

              // Keep the loading indicator visible while we refresh the conversation
              // We'll refresh the conversation list from the server
              await getTicketConversation();

              // Show success message
              Get.snackbar(
                "Success",
                "File uploaded successfully",
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 3),
              );

              // Now we can hide the loading indicator after the conversation is refreshed
              uploadingAttachment.value = false;
            } else {
              log('Response missing data field: $jsonResponse');
              uploadingAttachment.value = false;
            }
          } else {
            log('Upload response indicates failure: $jsonResponse');
            String errorMessage = "Server reported an error";
            if (jsonResponse.containsKey('data') &&
                jsonResponse['data'] is String) {
              errorMessage = jsonResponse['data'];
            }
            showBasicFailedSnackBar(message: errorMessage);
            uploadingAttachment.value = false;
          }
        } catch (e) {
          log('Error parsing response JSON: $e');
          showBasicFailedSnackBar(
              message: 'Error processing server response: $e');
          uploadingAttachment.value = false;
        }

        DispositionController.clearData();
      } else {
        var responseData = await response.stream.bytesToString();
        log('Upload failed. Status: ${response.statusCode}, Response: $responseData');
        // We'll keep the local version of the file in the conversation list
        showBasicFailedSnackBar(
            message: 'Failed to upload image to server. Please try again.');
        uploadingAttachment.value = false;
      }
    } catch (e, stackTrace) {
      log('Error during file upload: $e');
      log('Stack trace: $stackTrace');
      showBasicFailedSnackBar(message: 'An error occurred: $e');
      uploadingAttachment.value = false;
    }
  }

  final scrollController = ScrollController();
  void conversationBoxScrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200)).then((_) {
      if (!scrollController.hasClients) return;
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  // Helper method to determine attachment type based on file extension
  // This method is kept for reference but not used anymore

  void loadSavedConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList('conversationList');
    if (savedList != null) {
      conversationList.value = savedList
          .map((item) => ConversationUIModel.fromJson(jsonDecode(item)))
          .toList();
    }
  }

  // Helper method to save conversation list
  void _saveConversationList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedList =
          conversationList.map((item) => jsonEncode(item.toJson())).toList();
      prefs.setStringList('conversationList', savedList);
      log('Conversation list saved successfully');
    } catch (e) {
      log('Error saving conversation list: $e');
    }
  }

  // Public method for saving conversation list
  void saveConversationList() {
    _saveConversationList();
  }
}
