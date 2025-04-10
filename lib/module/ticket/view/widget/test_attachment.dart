// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../../model/ticket_conversation_list.response.dart';

// class AttachmentTile extends StatelessWidget {
//   final ConversationUIModel? conversation;

//   const AttachmentTile({Key? key, this.conversation}) : super(key: key);

//   Future<void> _downloadFile(BuildContext context, String fileUrl) async {
//     try {
//       // Request storage permission
//       var status = await Permission.storage.status;
//       if (!status.isGranted) {
//         await Permission.storage.request();
//       }

//       // Check if permission is granted
//       if (await Permission.storage.isGranted) {
//         // Start download
//         final response = await http.get(Uri.parse(fileUrl));
//         if (response.statusCode == 200) {
//           // Get the download directory
//           Directory? directory;
//           if (Platform.isAndroid) {
//             directory = Directory('/storage/emulated/0/Download');
//           } else {
//             directory = await getApplicationDocumentsDirectory();
//           }

//           // Create file name
//           String fileName = fileUrl.split('/').last;
//           String filePath = '${directory.path}/$fileName';

//           // Write the file
//           File file = File(filePath);
//           await file.writeAsBytes(response.bodyBytes);

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("File downloaded successfully: $filePath")),
//           );
//         } else {
//           throw Exception("Failed to download file");
//         }
//       } else {
//         throw Exception("Storage permission not granted");
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error downloading file: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (conversation?.attachmentUrl == null) {
//       return const SizedBox.shrink();
//     }

//     if (conversation?.attachmentType == "image") {
//       return _buildImageAttachment(context);
//     } else {
//       return _buildFileAttachment(context);
//     }
//   }

//   Widget _buildImageAttachment(BuildContext context) {
//     return Stack(
//       alignment: Alignment.topRight,
//       children: [
//         Image.network(
//           conversation!.attachmentUrl!,
//           errorBuilder: (context, error, stackTrace) {
//             print("Error loading image: $error");
//             return const Text("Error loading image");
//           },
//           loadingBuilder: (BuildContext context, Widget child,
//               ImageChunkEvent? loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded /
//                         loadingProgress.expectedTotalBytes!
//                     : null,
//               ),
//             );
//           },
//         ),
//         Positioned(
//           top: 8,
//           right: 8,
//           child: GestureDetector(
//             onTap: () => _downloadImage(context, conversation!.attachmentUrl!),
//             child: const CircleAvatar(
//               radius: 20,
//               backgroundColor: Colors.blue,
//               child: Icon(
//                 Icons.download,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFileAttachment(BuildContext context) {
//     String fileName = conversation!.attachmentUrl!.split('/').last;
//     return InkWell(
//       onTap: () => _downloadFile(context, conversation!.attachmentUrl!),
//       child: Container(
//         padding: EdgeInsets.all(8.w),
//         margin: EdgeInsets.only(bottom: 8.h),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(_getFileIcon(conversation?.attachmentType), size: 24.sp),
//             SizedBox(width: 8.w),
//             Flexible(
//               child: Text(
//                 "Download $fileName",
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontSize: 14.sp,
//                   decoration: TextDecoration.underline,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   IconData _getFileIcon(String? attachmentType) {
//     switch (attachmentType) {
//       case 'pdf':
//         return Icons.picture_as_pdf;
//       case 'doc':
//       case 'docx':
//         return Icons.description;
//       case 'xls':
//       case 'xlsx':
//         return Icons.table_chart;
//       case 'txt':
//         return Icons.text_snippet;
//       default:
//         return Icons.insert_drive_file;
//     }
//   }
// }
