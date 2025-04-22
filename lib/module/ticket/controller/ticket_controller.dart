import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isocial/domain/service/api_service.dart';
import 'package:isocial/domain/service/default_response.dart';
import 'package:isocial/notification_services.dart';
import 'package:isocial/storage/sharedPrefs.dart';
import 'package:isocial/utilities/message/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api_url.dart';
import '../dispositon/DispositonController.dart';
import '../model/ticket_conversation_list.response.dart';
import '../model/ticket_list_response.dart';
import '../model/agent_list_response.dart';
import '../view/ticket_list_view.dart';
import 'package:http/http.dart' as http;

class TicketController extends GetxController {
  // Callback for successful ticket transfer
  Function? onTransferSuccess;
  RxList<ConversationUIModel> conversationList = <ConversationUIModel>[].obs;
  RxString reply = "".obs;
  RxBool loading = true.obs;
  RxBool uploadingAttachment =
      false.obs; // For attachment upload loading indicator

  // For agent list dropdown
  RxList<AgentData> agentList = <AgentData>[].obs;
  RxBool loadingAgents = false.obs;

  // Notification services
  final NotificationServices _notificationServices = NotificationServices();

  @override
  void onInit() {
    loadSavedConversations();
    getTicketConversation();
    // Initialize notification services
    _notificationServices.initialize();
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
            } else if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp', 'flv']
                .contains(fileExtension)) {
              conversation.attachmentType = 'video';
            } else if (['mp3', 'wav', 'ogg', 'm4a', 'aac']
                .contains(fileExtension)) {
              conversation.attachmentType = 'audio';
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
  RxBool isAutoRefreshing = false.obs; // For auto-refresh indicator

// fetch ticket list
  void fetchTicketList({bool isAutoRefresh = false}) async {
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
      // If it's a manual refresh, show the full loading indicator
      // If it's an auto-refresh, show a subtle indicator
      if (isAutoRefresh) {
        isAutoRefreshing.value = true;
      } else {
        isLoading.value = true;
      }

      DefaultResponse defaultResponse = await ApiService.post(
          url: ApiUrls.ticketList, body: body, header: header);

      log("Ticket list API response success: ${defaultResponse.success}");
      if (defaultResponse.success) {
        log("Response data: ${defaultResponse.response}");

        try {
          TicketListResponseModel ticketListResponseModel =
              TicketListResponseModel.fromJson(defaultResponse.response);

          log("Parsed ticket list: ${ticketListResponseModel.ticketList?.length ?? 0} items");

          // Compare new list with current list to check for changes
          List<TicketListUIModel> newList =
              ticketListResponseModel.ticketList ?? [];
          bool hasNewTickets = _hasNewTickets(ticketList, newList);

          // Update the list
          ticketList.value = newList;
          log("Ticket list updated successfully");

          // If new tickets found, show a notification
          if (hasNewTickets) {
            // Count how many new tickets
            int newTicketCount = _countNewTickets(ticketList, newList);

            // Log the new tickets
            log("🔔 NEW TICKETS DETECTED: $newTicketCount new ticket(s)");

            // Show in-app snackbar if it's an auto-refresh
            if (isAutoRefresh) {
              Get.snackbar(
                "New Tickets",
                "$newTicketCount new ticket(s) have been received",
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }

            // Show system notification regardless of auto-refresh
            _notificationServices.showNewTicketNotification(
              count: newTicketCount,
              ticketInfo: "You have $newTicketCount new ticket(s) waiting",
            );
          }
        } catch (e) {
          log("Error parsing ticket list response: $e");
          if (!isAutoRefresh) {
            // Only show error for manual refresh
            showBasicFailedSnackBar(message: "Error parsing data: $e");
          }
        }
      } else {
        log("API call failed: ${defaultResponse.response['message']}");
        if (!isAutoRefresh) {
          // Only show error for manual refresh
          showBasicFailedSnackBar(message: defaultResponse.response['message']);
        }
      }
    } catch (e, stackTrace) {
      log("Exception in fetchTicketList: $e");
      log("Stack trace: $stackTrace");
      if (!isAutoRefresh) {
        // Only show error for manual refresh
        showBasicFailedSnackBar(message: "Error: $e");
      }
    } finally {
      isLoading.value = false;
      isAutoRefreshing.value = false;
    }
  }

  // Helper method to check if there are new tickets
  bool _hasNewTickets(
      RxList<TicketListUIModel> oldList, List<TicketListUIModel> newList) {
    // If new list is longer, there are definitely new tickets
    if (newList.length > oldList.length) {
      return true;
    }

    // Check for any new unique IDs that weren't in the old list
    Set<String?> oldIds = oldList.map((ticket) => ticket.uniqueId).toSet();
    for (var ticket in newList) {
      if (!oldIds.contains(ticket.uniqueId)) {
        return true;
      }
    }

    return false;
  }

  // Helper method to count how many new tickets
  int _countNewTickets(
      RxList<TicketListUIModel> oldList, List<TicketListUIModel> newList) {
    // If this is the first load, consider all tickets as new
    if (oldList.isEmpty) {
      return newList.length;
    }

    // Count tickets with IDs that weren't in the old list
    Set<String?> oldIds = oldList.map((ticket) => ticket.uniqueId).toSet();
    int count = 0;

    for (var ticket in newList) {
      if (!oldIds.contains(ticket.uniqueId)) {
        count++;
      }
    }

    return count;
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

  // Fetch agent list for transfer dropdown
  Future<void> fetchAgentList() async {
    try {
      log("Starting to fetch agent list...");
      loadingAgents.value = true;

      // Get token from SharedPrefs
      String? token = SharedPrefs.getString("token");
      if (token != null && token.isNotEmpty) {
        log("Token for agent list API is available");
      } else {
        log("WARNING: Token is null or empty!");
      }

      // Create request body
      // Map<String, dynamic> body = {
      //   "authorized_by": SharedPrefs.getString("authorized_by") ?? "",
      //   "username": SharedPrefs.getString("username") ?? ""
      // };

      Map<String, String> header = {
        "token": SharedPrefs.getString("token") ?? "",
        "content-type": "application/json"
      };

      log("Agent list API URL: ${ApiUrls.agentListUrl}");
      log("Agent list API body: ");
      log("Agent list API headers: $header");

      // Use POST instead of GET
      final response =
          await http.post(Uri.parse(ApiUrls.agentListUrl), headers: header);

      log("Agent list API response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        log("Agent list API raw response: ${response.body}");
        var jsonResponse = json.decode(response.body);
        log("Agent list API decoded response status: ${jsonResponse['status']}");

        AgentListResponse agentListResponse =
            AgentListResponse.fromJson(jsonResponse);

        log("Agent list response status: ${agentListResponse.status}");
        log("Agent list response data null check: ${agentListResponse.data != null}");
        if (agentListResponse.data != null) {
          log("Agent list data length: ${agentListResponse.data!.length}");
        }

        // Always set the agent list from the response, even if it's empty
        // This ensures we're using the latest data
        agentList.value = agentListResponse.data ?? [];

        if (agentListResponse.status == "200" && agentList.isNotEmpty) {
          log("Agent list fetched successfully: ${agentList.length} agents");

          // Log each agent for debugging
          for (var agent in agentList) {
            log("Agent: ${agent.username}, ${agent.fullName}, ${agent.role}");
          }
        } else {
          log("Failed to fetch agent list or list is empty. Status: ${agentListResponse.status}");
          if (jsonResponse['data'] is String) {
            log("Error message: ${jsonResponse['data']}");
          }
          // Don't show a snackbar here as it might be confusing to the user
          // The UI will show a retry button if needed
        }
      } else {
        log("Failed to fetch agent list. Status code: ${response.statusCode}");
        log("Response body: ${response.body}");
        showBasicFailedSnackBar(
            message: "Failed to fetch agent list. Server error.");
      }
    } catch (e, stackTrace) {
      log("Error fetching agent list: $e");
      log("Stack trace: $stackTrace");
      showBasicFailedSnackBar(message: "Error fetching agent list: $e");
    } finally {
      loadingAgents.value = false;
    }
  }

  // Transfer ticket to another agent
  Future<void> transferTicket(String username) async {
    // Variable to track if we need to show a loading dialog
    bool showLoading = true;

    try {
      // Log parameters for debugging
      String? uniqueId = SharedPrefs.getString("uniqueId");
      String? token = SharedPrefs.getString("token");

      log("Transfer ticket parameters:");
      log("username: $username");
      log("uniqueId: $uniqueId");
      log("token available: ${token != null && token.isNotEmpty}");

      // Validate required parameters
      if (uniqueId == null || uniqueId.isEmpty) {
        log("ERROR: uniqueId is null or empty");
        showBasicFailedSnackBar(
            message: "Cannot transfer ticket: Missing ticket ID");
        return;
      }

      if (username.isEmpty) {
        log("ERROR: username is empty");
        showBasicFailedSnackBar(
            message: "Cannot transfer ticket: Missing agent username");
        return;
      }

      // Show loading indicator safely
      if (showLoading && Get.context != null) {
        showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      }

      // Prepare request body with all required parameters
      Map<String, String> body = {
        "unique_id": uniqueId,
        "username": username,
      };

      Map<String, dynamic> header = {
        "content-type": "application/json",
        "token": token ?? "",
      };

      log("Transfer ticket API URL: ${ApiUrls.transferTicketUrl}");
      log("Transfer ticket API body: $body");
      log("Transfer ticket API headers: $header");

      // Call the transfer ticket API
      DefaultResponse defaultResponse = await ApiService.post(
          url: ApiUrls.transferTicketUrl, body: body, header: header);

      // Close loading dialog safely
      if (showLoading &&
          Get.context != null &&
          Navigator.canPop(Get.context!)) {
        Navigator.of(Get.context!).pop();
      }

      log("Transfer ticket API response success: ${defaultResponse.success}");
      log("Transfer ticket API response: ${defaultResponse.response}");

      if (defaultResponse.success) {
        log("Transfer successful, navigating to ticket list");

        // Store the success message in a static variable that will be accessed by TicketList
        SharedPrefs.setString("transfer_success_message",
            "Ticket transferred successfully to $username");

        // Use a callback to navigate from the UI layer
        // This avoids the contextless navigation issue
        if (onTransferSuccess != null) {
          log("Calling onTransferSuccess callback");
          onTransferSuccess!();
        } else {
          log("No onTransferSuccess callback provided");
        }
      } else {
        // Safely access the error message
        String errorMessage = "Failed to transfer ticket";
        try {
          if (defaultResponse.response.containsKey('message')) {
            errorMessage = defaultResponse.response['message'] ?? errorMessage;
          } else if (defaultResponse.response.containsKey('data')) {
            // Some APIs return error messages in the 'data' field
            errorMessage =
                defaultResponse.response['data']?.toString() ?? errorMessage;
          }
        } catch (e) {
          log("Error accessing response message: $e");
        }

        log("Transfer failed with error: $errorMessage");
        showBasicFailedSnackBar(message: errorMessage);
      }
    } catch (e, stackTrace) {
      // Close loading dialog safely if open
      if (showLoading &&
          Get.context != null &&
          Navigator.canPop(Get.context!)) {
        Navigator.of(Get.context!).pop();
      }

      log("Error transferring ticket: $e");
      log("Stack trace: $stackTrace");
      showBasicFailedSnackBar(message: "Error transferring ticket: $e");
    }
  }
}
