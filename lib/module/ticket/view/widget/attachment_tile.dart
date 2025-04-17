import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/ticket_conversation_list.response.dart';
import 'full_screen_image_view.dart';
import 'audio_player_widget.dart';
import 'video_player_widget.dart';
import '../../../../utilities/permission_service.dart';

class AttachmentTile extends StatelessWidget {
  final ConversationUIModel? conversation;

  const AttachmentTile({Key? key, this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (conversation?.attachmentUrl == null ||
        conversation?.attachmentUrl?.isEmpty == true) {
      return const SizedBox.shrink();
    }

    // Check attachment type
    if (conversation?.attachmentType == "image") {
      return _buildImageAttachment(context);
    } else if (conversation?.attachmentType == "audio" ||
        _isAudioFile(conversation?.attachmentUrl)) {
      return _buildAudioAttachment(context);
    } else if (conversation?.attachmentType == "video" ||
        _isVideoFile(conversation?.attachmentUrl)) {
      return _buildVideoAttachment(context);
    } else if (conversation?.attachmentType != null &&
        conversation?.attachmentType != "text") {
      return _buildFileAttachment(context);
    } else {
      return const SizedBox.shrink();
    }
  }

  // Check if the file is an audio file based on extension
  bool _isAudioFile(String? url) {
    if (url == null) return false;
    String extension = url.split('.').last.toLowerCase();
    return ['mp3', 'wav', 'ogg', 'm4a', 'aac'].contains(extension);
  }

  // Check if the file is a video file based on extension
  bool _isVideoFile(String? url) {
    if (url == null) return false;
    String extension = url.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp', 'flv']
        .contains(extension);
  }

  Widget _buildImageAttachment(BuildContext context) {
    // Generate a unique hero tag for this image
    final String heroTag =
        'image-${conversation?.attachmentUrl ?? conversation?.localFilePath ?? DateTime.now().millisecondsSinceEpoch}';

    return Stack(
      alignment: Alignment.topRight,
      children: [
        // Wrap the image in a GestureDetector to handle taps
        GestureDetector(
          onTap: () {
            // Navigate to full screen view when image is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImageView(
                  imageUrl: conversation?.attachmentUrl,
                  localFilePath: conversation?.localFilePath,
                  heroTag: heroTag,
                ),
              ),
            );
          },
          child: Hero(
            tag: heroTag,
            child: (conversation!.localFilePath != null &&
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
          ),
        ),
        // Download button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _downloadFile(context, conversation!.attachmentUrl!),
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

  Widget _buildAudioAttachment(BuildContext context) {
    String fileName = conversation!.attachmentUrl!.split('/').last;
    return AudioPlayerWidget(
      audioUrl: conversation!.attachmentUrl!,
      fileName: fileName,
    );
  }

  Widget _buildVideoAttachment(BuildContext context) {
    String fileName = conversation!.attachmentUrl!.split('/').last;
    return VideoPlayerWidget(
      videoUrl: conversation!.attachmentUrl!,
      fileName: fileName,
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

  Future<void> _downloadFile(BuildContext context, String fileUrl) async {
    try {
      // Request storage permission using the centralized permission service
      bool permissionGranted =
          await PermissionService.requestStoragePermission(context);
      if (!permissionGranted) {
        return; // Exit if permission not granted
      }

      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)),
                SizedBox(width: 10),
                Text("Downloading file..."),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Start download
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        // Get the download directory
        Directory? directory;
        if (Platform.isAndroid) {
          try {
            // Try to use the Download directory first
            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              // If it doesn't exist, fall back to app documents directory
              directory = await getApplicationDocumentsDirectory();
            }
          } catch (e) {
            // If there's any issue, fall back to app documents directory
            directory = await getApplicationDocumentsDirectory();
          }
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

        // Try to open the file
        try {
          await OpenFile.open(filePath);
        } catch (e) {
          debugPrint("Could not open file: $e");
          // Show a message that the file was downloaded but couldn't be opened
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File downloaded to: $filePath'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        throw Exception("Failed to download file");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error downloading file: $e")),
        );
      }
    }
  }
}
