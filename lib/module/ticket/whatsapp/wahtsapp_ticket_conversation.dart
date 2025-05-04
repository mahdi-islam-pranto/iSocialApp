import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../ticket/controller/ticket_controller.dart';
import '../controller/auto_loader_controller.dart';
import '../dispositon/DispositonController.dart';
import '../dispositon/TemplateDisposition.dart';
import '../dispositon/TypeDisposition.dart';
import '../view/ticket_list_view.dart';
import '../view/widget/attachment_preview_dialog.dart';
import 'widget/wa_owner_messageTile.dart';
import 'widget/wa_user_message_Tile.dart';

class WhatsappConversion extends StatefulWidget {
  final String userName;
  final String assignUser;
  final String pageNumber;
  final String wa_id;
  const WhatsappConversion(
      {super.key,
      required this.userName,
      required this.assignUser,
      required this.pageNumber,
      required this.wa_id});

  @override
  State<WhatsappConversion> createState() => _WhatsappConversionState();
}

class _WhatsappConversionState extends State<WhatsappConversion> {
  bool buttonVisible = true;
  GlobalKey<_WhatsappConversionState> refresh =
      GlobalKey<_WhatsappConversionState>();
  String progressCloseDropDownValue = "Progress";
  bool showDisposition = false;
  bool realtimeConversation = false;
  TicketController controller = Get.find();
  AutoLoaderController autoLoaderController = AutoLoaderController();

  @override
  void initState() {
    super.initState();

    controller.getWatsappTicketConversation();

    autoLoaderController.waAutoloderStart();

    // Add listener to uploadingAttachment to cancel the timer when upload completes
    controller.uploadingAttachment.listen((isUploading) {
      if (!isUploading) {
        _cancelUploadTimeoutTimer();
      }
    });
  }

  // Timer for attachment upload timeout
  Timer? _uploadTimeoutTimer;

  // Helper method to cancel the upload timeout timer
  void _cancelUploadTimeoutTimer() {
    if (_uploadTimeoutTimer != null && _uploadTimeoutTimer!.isActive) {
      _uploadTimeoutTimer!.cancel();
      _uploadTimeoutTimer = null;
    }
  }

  @override
  void dispose() {
    _cancelUploadTimeoutTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        autoLoaderController.waStop();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Flexible(
                  child: Text(
                widget.userName.toString(),
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black,
                ),
              )),
              Row(
                children: [
                  Text(
                    " (${widget.assignUser})",
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                  Text(
                    " -> ${widget.pageNumber}",
                    style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                  ),
                ],
              ),

              SizedBox(width: 10.w),
              // transfer button
              OutlinedButton(
                onPressed: () {
                  _showTransferDialog();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("Transfer"),
              )
            ],
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 15.sp,
              ),
              onPressed: () {
                Navigator.pop(context);
                autoLoaderController.waStop();
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
                  SizedBox(height: 10.h),

                  /// Chat List
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        reverse: true,
                        physics: const ScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Prevent conflict
                          itemCount: controller.wa_Messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final wc = controller.wa_Messages[index];
                            print('whatsapp conversion:> ${wc}');

                            return wc.senderType == "user"
                                ? WaUserMessage(userConversation: wc)
                                : WaOwnermassage(
                                    ownerConversation: wc,
                                    displayPhoneNumber: widget.pageNumber,
                                  );
                          },
                        ),
                      ),
                    ),
                  ),

                  /// Input & Buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(left: 10, right: 0),
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
                                onPressed: () => _showAttachmentDialog(context),
                                icon: const Icon(Icons.attachment_sharp,
                                    size: 24, color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        padding:
                            const EdgeInsets.only(right: 0, left: 0, bottom: 6),
                        onPressed: waSendReplay,
                        icon: const Icon(Icons.send,
                            size: 30, color: Colors.blueGrey),
                      ),
                    ],
                  ),

                  SizedBox(height: 5.h),

                  /// Sub-category Dropdown
                  Visibility(
                    visible: showDisposition,
                    child: const TypeDisposition(),
                  ),

                  /// Template and Progress Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 40.h,
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        child: const Center(child: TemplateDisposition()),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        height: 40.h,
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        child: Center(child: progressClose()),
                      ),
                    ],
                  ),

                  SizedBox(height: 25.h),
                ],
              );
            }),

            /// Overlay Loading Indicator
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
                                backgroundColor: Colors.white),
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

  Widget progressClose() {
    var progressClose = [
      "Progress",
      "Closed",
    ];

    return Container(
      height: 30.h, // Set a small height
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButton(
          isExpanded: true,
          underline: SizedBox(), // Initial Value
          value: progressCloseDropDownValue,
          icon: const Icon(Icons.keyboard_arrow_down),

          // Array list of items
          items: progressClose.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(
                items,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              progressCloseDropDownValue = newValue!;
              DispositionController.ticketStatus = progressCloseDropDownValue;
              if (progressCloseDropDownValue == "Closed") {
                showDisposition = true;
              } else {
                showDisposition = false;
              }
            });
          }),
    );
  }

  void waSendReplay() async {
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

      controller.waSendReplay();
    } else if (DispositionController.ticketStatus.contains("Closed") ||
        DispositionController.dispositionType.isNotEmpty ||
        DispositionController.dispositionCat.isNotEmpty ||
        DispositionController.dispositionSubCat.isNotEmpty ||
        DispositionController.labelId.isNotEmpty) {
      controller.waSendReplay();

      debugPrint("wa_Ticket closed: ${controller.waSendReplay}");

      if (mounted) {
        Navigator.pop(context);
        // show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('whatsapp ticket closed successfully'),
              backgroundColor: Colors.green),
        );
      }

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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        File imageFile = File(image.path);
        debugPrint('Picked image: ${imageFile.path}');

        // Show preview dialog instead of sending immediately
        _showAttachmentPreviewDialog(imageFile);
      } else {
        debugPrint('No image selected');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
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

  Future<void> _captureImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        File imageFile = File(image.path);
        debugPrint('Captured image: ${imageFile.path}');

        // Show preview dialog instead of sending immediately
        _showAttachmentPreviewDialog(imageFile);
      } else {
        debugPrint('No image captured');
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    }
  }

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

  // void attachmentReplay(File file) async {
  //   try {
  //     // Show loading indicator immediately
  //     controller.uploadingAttachment.value = true;
  //
  //     // Set a timeout timer (30 seconds)
  //     _uploadTimeoutTimer = Timer(const Duration(seconds: 30), () {
  //       // If this timer fires, it means the upload took too long
  //       if (controller.uploadingAttachment.value) {
  //         debugPrint("Attachment upload timed out after 30 seconds");
  //         controller.uploadingAttachment.value = false;
  //
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text(
  //                   'Attachment upload timed out. Please check your connection and try again.'),
  //               backgroundColor: Colors.red,
  //               duration: Duration(seconds: 5),
  //             ),
  //           );
  //         }
  //       }
  //     });
  //
  //     // Debugging print statements
  //     debugPrint("Attachment replay started with file: ${file.path}");
  //
  //     DispositionController.ticketStatus = progressCloseDropDownValue;
  //
  //     // Check file and status
  //     if (file.path.isNotEmpty) {
  //       // Setting attachment data for debug purposes
  //       DispositionController.attachmentData = file.path.split('/').last;
  //       debugPrint("Attachment Data: ${DispositionController.attachmentData}");
  //
  //       controller.waAttachmentReplayController(file);
  //     } else {
  //       debugPrint("No file path or invalid ticket status.");
  //       _cancelUploadTimeoutTimer();
  //       controller.uploadingAttachment.value = false;
  //       return;
  //     }
  //
  //     SharedPreferences sharedPreferences =
  //         await SharedPreferences.getInstance();
  //     sharedPreferences.setString(
  //         "attachmentData", DispositionController.attachmentData);
  //     debugPrint(
  //         "shared Attachment data :  ${sharedPreferences.getString("attachmentData")}}");
  //
  //     if (DispositionController.ticketStatus.contains("Progress") &&
  //         DispositionController.attachmentData.isNotEmpty) {
  //       controller.waAttachmentReplayController(file);
  //       // The controller will handle setting uploadingAttachment.value = false
  //       // We'll cancel the timer when the upload completes or fails in the controller
  //     } else if (DispositionController.ticketStatus.contains("Closed") &&
  //         DispositionController.dispositionType.isNotEmpty &&
  //         DispositionController.dispositionCat.isNotEmpty &&
  //         DispositionController.dispositionSubCat.isNotEmpty &&
  //         DispositionController.labelId.isNotEmpty) {
  //       controller.waAttachmentReplayController(file);
  //       // The controller will handle setting uploadingAttachment.value = false
  //
  //       setState(() {
  //         if (realtimeConversation) {
  //           realtimeConversation = false;
  //         } else if (!realtimeConversation) {
  //           realtimeConversation = true;
  //         }
  //       });
  //     } else {
  //       //replayRequest();
  //       _cancelUploadTimeoutTimer();
  //       controller.uploadingAttachment.value = false;
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //               content: Text(
  //                   'Please select a disposition type for closed tickets')),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Error in attachmentReplay: $e");
  //     _cancelUploadTimeoutTimer();
  //     controller.uploadingAttachment.value = false;
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text('Error processing attachment: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }
  void attachmentReplay(File file) async {
    try {
      // Show loading indicator immediately
      controller.uploadingAttachment.value = true;

      // Set a timeout timer (30 seconds)
      _uploadTimeoutTimer = Timer(const Duration(seconds: 30), () {
        // If this timer fires, it means the upload took too long
        if (controller.uploadingAttachment.value) {
          debugPrint("Attachment upload timed out after 30 seconds");
          controller.uploadingAttachment.value = false;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Attachment upload timed out. Please check your connection and try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      });

      // Debugging print statements
      debugPrint("Attachment replay started with file: ${file.path}");

      DispositionController.ticketStatus = progressCloseDropDownValue;

      // Check file path is valid
      if (file.path.isEmpty) {
        debugPrint("No file path provided.");
        _cancelUploadTimeoutTimer();
        controller.uploadingAttachment.value = false;
        return;
      }

      // Setting attachment data for debugging
      DispositionController.attachmentData = file.path.split('/').last;
      debugPrint("Attachment Data: ${DispositionController.attachmentData}");

      // Save to shared preferences
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(
          "attachmentData", DispositionController.attachmentData);
      debugPrint(
          "shared Attachment data: ${sharedPreferences.getString("attachmentData")}");

      // Check if ticket is being closed but disposition is incomplete
      if (DispositionController.ticketStatus.contains("Closed") &&
          (DispositionController.dispositionType.isEmpty ||
              DispositionController.dispositionCat.isEmpty ||
              DispositionController.dispositionSubCat.isEmpty ||
              DispositionController.labelId.isEmpty)) {
        _cancelUploadTimeoutTimer();
        controller.uploadingAttachment.value = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Please select a disposition type for closed tickets')),
          );
        }
        return;
      }

      // Send the attachment only once
      controller.waAttachmentReplayController(file);

      // Update realtime conversation state if needed
      if (DispositionController.ticketStatus.contains("Closed")) {
        setState(() {
          realtimeConversation = !realtimeConversation;
        });
      }
    } catch (e) {
      debugPrint("Error in attachmentReplay: $e");
      _cancelUploadTimeoutTimer();
      controller.uploadingAttachment.value = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error processing attachment: ${e.toString()}')),
        );
      }
    }
  }

  // Show transfer dialog with agent list dropdown
  void _showTransferDialog() {
    // Check if we're still mounted
    if (!mounted) return;

    // Start the async process
    _prepareAndShowTransferDialog();
  }

  // Helper method to prepare and show the transfer dialog
  Future<void> _prepareAndShowTransferDialog() async {
    try {
      // Get the current ticket's uniqueId
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uniqueId = prefs.getString("uniqueId");
      debugPrint("Current ticket uniqueId: $uniqueId");

      if (uniqueId == null || uniqueId.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot transfer ticket: Missing ticket ID'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Refresh the agent list
      debugPrint("Opening transfer dialog, fetching fresh agent list");
      controller.agentList.clear();
      await controller.fetchAgentList();
      debugPrint("Agent list fetched, count: ${controller.agentList.length}");

      // Check if we're still mounted after the async operations
      if (!mounted) return;

      // Selected agent username for the dialog
      String? selectedUsername;

      // Now show the dialog with the current context
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Transfer Ticket'),
            content: Obx(() {
              debugPrint(
                  "Dialog Obx rebuilding, loadingAgents: ${controller.loadingAgents.value}, agentList length: ${controller.agentList.length}");

              if (controller.loadingAgents.value) {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.agentList.isEmpty) {
                debugPrint("Agent list is empty in the dialog");
                return SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No agents available'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            controller.fetchAgentList();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              debugPrint(
                  "Building dropdown with ${controller.agentList.length} agents");
              return StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Select agent to transfer this ticket (${controller.agentList.length} available):'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedUsername,
                            hint: const Text('Select Agent'),
                            isExpanded: true,
                            items: controller.agentList.map((agent) {
                              return DropdownMenuItem<String>(
                                value: agent.username,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: agent.username ?? "Unknown",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " - ${agent.status ?? ""}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              debugPrint("Selected agent: $value");
                              setState(() {
                                selectedUsername = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedUsername != null) {
                    debugPrint("Transferring ticket to: $selectedUsername");
                    Navigator.pop(dialogContext);

                    // Set the callback for successful transfer
                    controller.onTransferSuccess = () {
                      debugPrint("Transfer success callback triggered");
                      if (mounted) {
                        // Navigate to ticket list page, but preserve the navigation stack
                        // First pop back to the previous screen (likely the dashboard)
                        Navigator.of(context).pop();

                        // Then navigate to the ticket list
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const TicketList()));
                      }
                    };

                    // Call the transfer method
                    controller.watransferTicket(selectedUsername!);
                  } else {
                    debugPrint("No agent selected for transfer");
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Please select an agent'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Transfer'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint("Error preparing or showing transfer dialog: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error preparing transfer dialog: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
