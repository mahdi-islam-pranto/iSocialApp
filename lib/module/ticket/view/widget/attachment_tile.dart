import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../model/ticket_conversation_list.response.dart';
import 'full_screen_image_view.dart';

class AttachmentTile extends StatelessWidget {
  final ConversationUIModel? conversation;

  const AttachmentTile({Key? key, this.conversation}) : super(key: key);

// download image
  Future<void> _downloadImage(BuildContext context, String imageUrl) async {
    try {
      // Check Android version to determine which permissions to request
      if (Platform.isAndroid) {
        // Request appropriate permissions based on Android version
        bool permissionGranted = await _requestStoragePermission(context);
        if (!permissionGranted) {
          return; // Exit if permission not granted
        }
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
                Text("Downloading image..."),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Save the image
        final result = await ImageGallerySaver.saveImage(
          response.bodyBytes,
          quality: 100,
          name: "downloaded_image_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (result['isSuccess']) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Image downloaded successfully",
                      style: TextStyle(color: Colors.white),
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
          throw Exception("Failed to save image");
        }
      } else {
        throw Exception("Failed to download image");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error downloading image: $e")),
        );
      }
    }
  }

  Future<void> _downloadFile(BuildContext context, String fileUrl) async {
    try {
      // Check Android version to determine which permissions to request
      if (Platform.isAndroid) {
        // Request appropriate permissions based on Android version
        bool permissionGranted = await _requestStoragePermission(context);
        if (!permissionGranted) {
          return; // Exit if permission not granted
        }
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
          // Continue anyway as the file is still downloaded
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
            onTap: () => _downloadImage(context, conversation!.attachmentUrl!),
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

  // Request storage permission based on Android version
  Future<bool> _requestStoragePermission(BuildContext context) async {
    // For Android 13+ (API level 33+)
    if (Platform.isAndroid) {
      try {
        // Try multiple permission approaches
        // First try storage permission
        var storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          storageStatus = await Permission.storage.request();
        }

        // If storage permission is granted, return true
        if (storageStatus.isGranted) {
          return true;
        }

        // If we're here, storage permission was denied
        // Try external storage permission
        var externalStorageStatus =
            await Permission.manageExternalStorage.status;
        if (!externalStorageStatus.isGranted) {
          externalStorageStatus =
              await Permission.manageExternalStorage.request();
        }

        // If external storage permission is granted, return true
        if (externalStorageStatus.isGranted) {
          return true;
        }

        // If we're here, both permissions were denied
        // Show explanation dialog
        if (context.mounted) {
          _showPermissionExplanationDialog(context);
        }
        return false;
      } catch (e) {
        debugPrint("Error requesting permissions: $e");
        return false;
      }
    }

    // For non-Android platforms, return true
    return true;
  }

  // Show a dialog explaining why we need storage permission
  void _showPermissionExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
              'To download files and images, this app needs permission to access your device storage. '
              'Please grant storage permission in the app settings.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Open app settings so user can enable permission
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
