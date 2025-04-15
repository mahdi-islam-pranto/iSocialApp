import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:isocial/module/ticket/controller/ticket_controller.dart';
import 'package:isocial/module/ticket/dispositon/TemplateDisposition.dart';
import 'package:isocial/module/ticket/dispositon/TypeDisposition.dart';
import 'package:isocial/module/ticket/dispositon/DispositonController.dart';
import 'package:isocial/module/ticket/view/widget/attachment_preview_dialog.dart';
import 'package:isocial/module/ticket/view/widget/own_message_tile.dart';
import 'package:isocial/module/ticket/view/widget/user_message_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controller/auto_loader_controller.dart';
import 'model/ticket_conversation_list.response.dart';

class TicketConversation extends StatefulWidget {
  const TicketConversation(
      {Key? key,
      required this.fullName,
      required this.dataType,
      required this.pageName})
      : super(key: key);
  final String fullName;
  final String dataType;
  final String pageName;

  @override
  State<TicketConversation> createState() => _TicketConversationState();
}

class _TicketConversationState extends State<TicketConversation> {
  bool buttonVisible = true;
  GlobalKey<_TicketConversationState> refresh =
      GlobalKey<_TicketConversationState>();
  String progressCloseDropDownValue = "Progress";
  bool showDisposition = false;
  bool realtimeConversation = false;
  TicketController controller = Get.find();

  AutoLoaderController autoLoaderController = AutoLoaderController();

  @override
  void initState() {
    controller.getTicketConversation();
    autoLoaderController.start();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        autoLoaderController.stop();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Flexible(child: Text(widget.fullName.toString())),
              Row(
                children: [
                  Text(
                    " (${widget.dataType})",
                    style: TextStyle(color: Colors.grey, fontSize: 18.sp),
                  ),
                  Text(
                    " -> ${widget.pageName}",
                    style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                  ),
                ],
              ),
            ],
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 15.sp,
              ),
              onPressed: () {
                Navigator.pop(context);
                autoLoaderController.stop();
              }),
        ),
        body: Stack(
          children: [
            // Main content
            Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  //Simple padding
                  SizedBox(
                    height: 10.h,
                  ),

                  Expanded(
                    child: Obx(() {
                      if (controller.loading.value) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: SingleChildScrollView(
                          reverse: true,
                          physics: const ScrollPhysics(),

                          //  controller: controller.scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: ListView.builder(
                            shrinkWrap: true,
                            primary: true,
                            // reverse: true,
                            physics: const ScrollPhysics(),
                            itemCount: controller.conversationList.length,
                            itemBuilder: (BuildContext context, int index) {
                              ConversationUIModel conversation =
                                  controller.conversationList[index];

                              return conversation.senderType == "user"
                                  ? UserMessageTile(conversation: conversation)
                                  : OwnMessageTile(
                                      conversation: conversation,
                                      pageName: widget.pageName,
                                    );
                            },
                          ),
                        ),
                      );
                    }),
                  ),

                  /// Type massage + sand button

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        // Message input box
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 10, right: 0, bottom: 0),
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextField(
                                controller:
                                    DispositionController.dispositionController,
                                maxLines: null,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      width: 1,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  hintText: "Type a message...",
                                  filled: true,
                                  fillColor: const Color(0xfff7fafd),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  _showAttachmentDialog(context);
                                },
                                icon: const Icon(
                                  Icons.attachment_sharp,
                                  size: 24,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Message sent button
                      IconButton(
                        padding: const EdgeInsets.only(right: 0, left: 0),
                        onPressed: () async {
                          // Add your send function here
                          sendReplay();
                        },
                        icon: const Icon(
                          Icons.send,
                          size: 30,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  //Simple Padding
                  SizedBox(
                    height: 10.h,
                  ),
                  // Sub Category dropdown dispositions
                  Visibility(
                    visible: showDisposition,
                    child: const TypeDisposition(),
                  ),

                  /// template and progress
                  ///

                  //main disposition
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40.h,
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        // decoration: BoxDecoration(
                        //   border: Border.all(color: Colors.grey,width: 1),
                        //   borderRadius: BorderRadius.circular(3),
                        // ),
                        child: const Center(child: TemplateDisposition()),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Container(
                        height: 40.h,
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(child: progressClose()),
                      ),
                    ],
                  ),
                  //simple disposition
                  SizedBox(
                    height: 10.h,
                  )
                ],
              );
            }),

            // Overlay loading indicator for attachment uploads
            Obx(() => controller.uploadingAttachment.value
                ? Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            const CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Sending attachment...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Text(
                            //   'Please wait while your image is being uploaded',
                            //   style: TextStyle(fontSize: 14.sp),
                            //   textAlign: TextAlign.center,
                            // ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  void sendReplay() async {
    //Get replay string from inputField
    DispositionController.messageData =
        DispositionController.dispositionController.text.trim();

    DispositionController.dispositionController.clear();

    DispositionController.ticketStatus = progressCloseDropDownValue;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(
        "messageData", DispositionController.messageData);
    debugPrint(
        "shared Message data :  ${sharedPreferences.getString("messageData")}}");

    if (DispositionController.ticketStatus.contains("Progress") &&
        DispositionController.messageData.isNotEmpty) {
      //clear input text field

      controller.sendReplay();
    } else if (DispositionController.ticketStatus.contains("Closed") &&
        DispositionController.dispositionType.isNotEmpty &&
        DispositionController.dispositionCat.isNotEmpty &&
        DispositionController.dispositionSubCat.isNotEmpty &&
        DispositionController.labelId.isNotEmpty) {
      controller.sendReplay();

      setState(() {
        if (realtimeConversation) {
          realtimeConversation = false;
        } else if (!realtimeConversation) {
          realtimeConversation = true;
        }
      });
    } else {
      //replayRequest();
    }
  }

  void attachmentReplay(File file) async {
    try {
      // Show loading indicator immediately
      controller.uploadingAttachment.value = true;

      // Debugging print statements
      debugPrint("Attachment replay started with file: ${file.path}");

      DispositionController.ticketStatus = progressCloseDropDownValue;

      // Check file and status
      if (file.path.isNotEmpty) {
        // Setting attachment data for debug purposes
        DispositionController.attachmentData = file.path.split('/').last;
        debugPrint("Attachment Data: ${DispositionController.attachmentData}");

        // controller.attachmentReplayController(file);
      } else {
        debugPrint("No file path or invalid ticket status.");
      }

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(
          "attachmentData", DispositionController.attachmentData);
      debugPrint(
          "shared Attachment data :  ${sharedPreferences.getString("attachmentData")}}");

      if (DispositionController.ticketStatus.contains("Progress") &&
          DispositionController.attachmentData.isNotEmpty) {
        controller.attachmentReplayController(file);
      } else if (DispositionController.ticketStatus.contains("Closed") &&
          DispositionController.dispositionType.isNotEmpty &&
          DispositionController.dispositionCat.isNotEmpty &&
          DispositionController.dispositionSubCat.isNotEmpty &&
          DispositionController.labelId.isNotEmpty) {
        controller.attachmentReplayController(file);

        setState(() {
          if (realtimeConversation) {
            realtimeConversation = false;
          } else if (!realtimeConversation) {
            realtimeConversation = true;
          }
        });
      } else {
        //replayRequest();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Please select a disposition type for closed tickets')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error in attachmentReplay: $e");
      controller.uploadingAttachment.value = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error processing attachment: ${e.toString()}')),
        );
      }
    }
  }

  // Attachment Send API

  Widget progressClose() {
    var progressClose = [
      "Progress",
      //"Working"
      "Closed"
    ];

    /// progress
    return Container(
      color: Colors.white,
      child: Container(
        height: 30.h,
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        child: DropdownButton(
            isExpanded: true,
            underline: const SizedBox(),
            // Initial Value
            value: progressCloseDropDownValue,

            // Down Arrow Icon
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black54,
            ),

            // Array list of items
            items: progressClose.map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(
                  items,
                  style: TextStyle(fontSize: 13.sp),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                if (newValue == "Closed") {
                  progressCloseDropDownValue = "Closed";
                  DispositionController.ticketStatus = "Closed";
                  showDisposition = true;
                }

                ///working
                // if(newValue == "Working"){
                //
                //   progressCloseDropDownValue = "Working";
                //   DispositionController.ticketStatus = "Working";
                //
                //   showDisposition = true;
                // }

                else {
                  progressCloseDropDownValue = "Progress";
                  DispositionController.ticketStatus = "Progress";
                  showDisposition = false;
                }
              });
            }),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      debugPrint('Picked image from gallery: ${file.path}');

      // Show preview dialog instead of sending immediately
      _showAttachmentPreviewDialog(file);
    }
  }

  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      File file = File(image.path);
      debugPrint('Captured image: ${file.path}');

      // Show preview dialog instead of sending immediately
      _showAttachmentPreviewDialog(file);
    }
  }

  // Future<void> _pickFile() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
  //   );

  //   if (result != null) {
  //     File file = File(result.files.single.path!);
  //     print('Picked file: ${file.path}');

  //     // Call the attachmentReplay function
  //     attachmentReplay(file);
  //   }
  // }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        String fileExtension = fileName.split('.').last.toLowerCase();
        debugPrint('Picked file: ${file.path}, extension: $fileExtension');

        // Show preview dialog instead of sending immediately
        _showAttachmentPreviewDialog(file);
      } else {
        debugPrint('No file selected or file path is null');
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _showAttachmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an action'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Camera option
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt, size: 30),
                    onPressed: () {
                      _captureImage();
                      Navigator.of(context).pop();
                    },
                  ),
                  const Text('Camera')
                ],
              ),
              // Gallery option
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library, size: 30),
                    onPressed: () {
                      _pickImage();
                      Navigator.of(context).pop();
                    },
                  ),
                  const Text('Gallery')
                ],
              ),
              // File attachment option
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, size: 30),
                    onPressed: () {
                      _pickFile();
                      Navigator.of(context).pop();
                    },
                  ),
                  const Text('File')
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttachmentPreviewDialog(File file) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AttachmentPreviewDialog(
          file: file,
          onConfirm: () {
            Navigator.of(context).pop();
            // Send the attachment if confirmed
            attachmentReplay(file);
          },
          onCancel: () {
            Navigator.of(context).pop();
            // Do nothing if canceled
          },
        );
      },
    );
  }
}
