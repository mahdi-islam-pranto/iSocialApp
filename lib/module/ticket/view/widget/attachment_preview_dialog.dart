import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as path;

class AttachmentPreviewDialog extends StatefulWidget {
  final File file;
  final Function() onConfirm;
  final Function() onCancel;

  const AttachmentPreviewDialog({
    Key? key,
    required this.file,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<AttachmentPreviewDialog> createState() =>
      _AttachmentPreviewDialogState();
}

class _AttachmentPreviewDialogState extends State<AttachmentPreviewDialog> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final String fileName = path.basename(widget.file.path);
    final String fileExtension = path.extension(widget.file.path).toLowerCase();
    final bool isImage =
        ['.jpg', '.jpeg', '.png', '.gif'].contains(fileExtension);
    final bool isVideo = [
      '.mp4',
      '.mov',
      '.avi',
      '.mkv',
      '.webm',
      '.3gp',
      '.flv'
    ].contains(fileExtension);
    final bool isAudio =
        ['.mp3', '.wav', '.ogg', '.m4a', '.aac'].contains(fileExtension);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 300.w,
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Confirm Attachment',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),

            // File name
            Text(
              fileName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16.h),

            // Preview
            Container(
              constraints: BoxConstraints(
                maxHeight: 250.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: _buildPreview(isImage, isVideo, isAudio, fileExtension),
              ),
            ),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button
                ElevatedButton(
                  onPressed: _isSending ? null : widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    disabledBackgroundColor: Colors.grey.shade100,
                    disabledForegroundColor: Colors.grey.shade400,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),

                // Confirm button
                ElevatedButton(
                  onPressed: _isSending
                      ? null
                      : () {
                          setState(() {
                            _isSending = true;
                          });
                          widget.onConfirm();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    disabledBackgroundColor: Colors.blue.shade200,
                  ),
                  child: _isSending
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : Text(
                          'Send',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(
      bool isImage, bool isVideo, bool isAudio, String fileExtension) {
    if (isImage) {
      return Image.file(
        widget.file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPreview('Could not load image preview');
        },
      );
    } else if (isVideo) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam,
                size: 50.sp,
                color: Colors.white70,
              ),
              SizedBox(height: 8.h),
              Text(
                'Video File',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isAudio) {
      return Container(
        color: Colors.blue.shade50,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.audiotrack,
                size: 50.sp,
                color: Colors.blue,
              ),
              SizedBox(height: 8.h),
              Text(
                'Audio File',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // For other file types
      return Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFileIcon(fileExtension),
                size: 50.sp,
                color: Colors.blue.shade700,
              ),
              SizedBox(height: 8.h),
              Text(
                'File Attachment',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildErrorPreview(String message) {
    return Container(
      color: Colors.grey.shade200,
      height: 150.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40.sp,
              color: Colors.red,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                color: Colors.red.shade800,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileExtension) {
    switch (fileExtension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.txt':
        return Icons.text_snippet;
      case '.zip':
      case '.rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
}
