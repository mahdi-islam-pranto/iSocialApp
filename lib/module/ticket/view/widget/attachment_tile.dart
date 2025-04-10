import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/ticket_conversation_list.response.dart';

class AttachmentTile extends StatelessWidget {
  final ConversationUIModel? conversation;

  const AttachmentTile({Key? key, this.conversation}) : super(key: key);

  Future<void> _downloadImage(BuildContext context, String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final result = await ImageGallerySaver.saveImage(
          response.bodyBytes,
          quality: 100,
          name: "downloaded_image_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green, // Background color of the snackbar
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.white), // Icon for success
                  SizedBox(width: 10),
                  Text("Image downloaded successfully",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
              duration: Duration(
                  seconds: 3), // How long the snackbar will be displayed
              behavior: SnackBarBehavior.floating, // Floating snackbar design
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          throw Exception("Failed to save image");
        }
      } else {
        throw Exception("Failed to download image");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading image: $e")),
      );
    }
  }

  Future<void> _openFile(BuildContext context, String fileUrl) async {
    try {
      if (await canLaunch(fileUrl)) {
        await launch(fileUrl);
      } else {
        final result = await OpenFile.open(fileUrl);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Cannot open file: ${result.message}")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening file: $e")),
      );
    }
  }

  Future<void> _downloadFile(BuildContext context, String fileUrl) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        // Start download
        final response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode == 200) {
          // Get the download directory
          Directory? directory;
          if (Platform.isAndroid) {
            directory = Directory('/storage/emulated/0/Download');
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          // Create file name
          String fileName = fileUrl.split('/').last;
          String filePath = '${directory.path}/$fileName';

          // Write the file
          File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          debugPrint("File downloaded to: $filePath");
          OpenFile.open(filePath);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Expanded(
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "File downloaded successfully to",
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Text(
                      filePath,
                      maxLines: 3,
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          throw Exception("Failed to download file");
        }
      } else {
        throw Exception("Storage permission not granted");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading file: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (conversation?.attachmentUrl == null ||
        conversation?.attachmentUrl?.isEmpty == true) {
      return const SizedBox.shrink();
    }

    if (conversation?.attachmentType == "image") {
      return _buildImageAttachment(context);
    } else if (conversation?.attachmentType != null &&
        conversation?.attachmentType != "text") {
      return _buildFileAttachment(context);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildImageAttachment(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        // Check if it's a local file or a remote URL
        // First check if we have a localFilePath, otherwise use attachmentUrl
        (conversation!.localFilePath != null &&
                conversation!.localFilePath!.isNotEmpty)
            ? Image.file(
                File(conversation!.localFilePath!),
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("Error loading local image: $error");
                  return const Text("Error loading image");
                },
              )
            : Image.network(
                conversation!.attachmentUrl!,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("Error loading network image: $error");
                  return const Text("Error loading image");
                },
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => (conversation!.localFilePath != null &&
                    conversation!.localFilePath!.isNotEmpty)
                ? _openLocalFile(context, conversation!.localFilePath!)
                : _downloadImage(context, conversation!.attachmentUrl!),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.download,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileAttachment(BuildContext context) {
    String fileName = conversation!.attachmentUrl!.split('/').last;
    return InkWell(
      onTap: () => _downloadFile(context, conversation!.attachmentUrl!),
      child: Container(
        padding: EdgeInsets.all(8.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getFileIcon(conversation?.attachmentUrl), size: 24.sp),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                "Download $fileName",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14.sp,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to check if a path is a local file
  bool _isLocalFile(String path) {
    return path.startsWith('/') ||
        path.startsWith('file://') ||
        path.contains('/data/') ||
        path.contains('/storage/');
  }

  // Open a local file
  Future<void> _openLocalFile(BuildContext context, String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot open file: ${result.message}")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening file: $e")),
        );
      }
    }
  }

  IconData _getFileIcon(String? attachmentUrl) {
    if (attachmentUrl == null) return Icons.insert_drive_file;

    String extension = attachmentUrl.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'mp3':
      case 'wav':
      case 'ogg':
        return Icons.audio_file;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
}
