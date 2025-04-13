import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String fileName;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    try {
      // Initialize video player controller
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

      try {
        // Initialize the controller and wait for it to be ready
        await _videoPlayerController.initialize();

        // Create chewie controller
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error initializing video player controller: $e");
        // If we can't initialize the video player, provide a fallback
        _handleVideoPlayerError();
      }
    } catch (e) {
      debugPrint("Error creating video player: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Unable to play video. You can download it to view.";
        });
      }
    }
  }

  void _handleVideoPlayerError() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        // Instead of showing an error message, we'll show a download button
        // with a preview image
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _downloadVideo() async {
    try {
      setState(() {
        _isDownloading = true;
      });

      // Request storage permission
      bool permissionGranted = await _requestStoragePermission();
      if (!permissionGranted) {
        setState(() {
          _isDownloading = false;
        });
        return;
      }

      // Download the file
      final response = await http.get(Uri.parse(widget.videoUrl));
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
        String filePath = '${directory.path}/${widget.fileName}';

        // Write the file
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
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
                        "Video downloaded successfully to",
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
        throw Exception("Failed to download video");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error downloading video: $e")),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<bool> _requestStoragePermission() async {
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
        if (mounted) {
          _showPermissionExplanationDialog();
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

  void _showPermissionExplanationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
              'To download video files, this app needs permission to access your device storage. '
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SpinKitWave(
            color: Colors.blue,
            size: 30.sp,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      // Show a more user-friendly error with download option
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail placeholder
            Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // File name and download button
            Container(
              padding: EdgeInsets.only(top: 12.h),
              child: Row(
                children: [
                  Icon(Icons.video_file, color: Colors.blue, size: 24.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      widget.fileName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _isDownloading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue),
                          ),
                        )
                      : ElevatedButton.icon(
                          icon: Icon(Icons.download, size: 18.sp),
                          label: Text("Download",
                              style: TextStyle(fontSize: 12.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                          ),
                          onPressed: _downloadVideo,
                        ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // If video player is initialized successfully
    if (_chewieController != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Chewie(controller: _chewieController!),
            ),
          ),

          // File name and download button
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            child: Row(
              children: [
                Icon(Icons.video_file, color: Colors.blue, size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.fileName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _isDownloading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.download, size: 24.sp),
                        color: Colors.blue,
                        onPressed: _downloadVideo,
                      ),
              ],
            ),
          ),
        ],
      );
    }

    // Fallback UI when video player initialization fails but no error message
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail placeholder
          Container(
            height: 150.h,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Video preview not available",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // File name and download button
          Container(
            padding: EdgeInsets.only(top: 12.h),
            child: Row(
              children: [
                Icon(Icons.video_file, color: Colors.blue, size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.fileName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _isDownloading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : ElevatedButton.icon(
                        icon: Icon(Icons.download, size: 18.sp),
                        label:
                            Text("Download", style: TextStyle(fontSize: 12.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                        ),
                        onPressed: _downloadVideo,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
