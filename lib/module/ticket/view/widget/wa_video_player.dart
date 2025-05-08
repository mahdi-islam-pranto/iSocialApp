import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import '../../../../utilities/permission_service.dart';

class WaVideoPlayer extends StatefulWidget {
  final String wa_videoUrl;
  final String wa_fileName;

  const WaVideoPlayer({
    Key? key,
    required this.wa_videoUrl,
    required this.wa_fileName,
  }) : super(key: key);

  @override
  State<WaVideoPlayer> createState() => _WaVideoPlayerState();
}

class _WaVideoPlayerState extends State<WaVideoPlayer> {
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
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.wa_videoUrl));
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()),
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
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Video init error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Unable to play video. You can download it to view.";
        });
      }
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
      setState(() => _isDownloading = true);

      bool permissionGranted =
          await PermissionService.requestStoragePermission(context);
      if (!permissionGranted) {
        setState(() => _isDownloading = false);
        return;
      }

      final response = await http.get(Uri.parse(widget.wa_videoUrl));
      if (response.statusCode == 200) {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getApplicationDocumentsDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        String filePath = '${directory.path}/${widget.wa_fileName}';
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
                      Text("Video downloaded successfully",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Text(filePath,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        throw Exception("Download failed");
      }
    } catch (e) {
      if (mounted) {
        print("Download error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download error: $e")),
        );
      }
    } finally {
      setState(() => _isDownloading = false);
    }
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
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    Icon(Icons.videocam_off, color: Colors.white, size: 40.sp),
                    SizedBox(height: 8.h),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.video_file, color: Colors.blue, size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.wa_fileName,
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
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
          ],
        ),
      );
    }

    if (_chewieController != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            child: Row(
              children: [
                Icon(Icons.video_file, color: Colors.blue, size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.wa_fileName,
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

    return const SizedBox.shrink();
  }
}
