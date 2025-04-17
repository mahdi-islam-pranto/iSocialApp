import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check and request storage permissions based on Android version
  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      // For non-Android platforms, return true as we don't need special handling
      return true;
    }

    try {
      // Get Android SDK version
      // For Android 13+ (API level 33+), we need to request specific media permissions
      // For older versions, we can use the storage permission
      
      // First try with storage permission (works for Android < 13)
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        // Show explanation dialog before requesting permission
        final bool shouldRequest = await _showPermissionRationaleDialog(
          context,
          'Storage Access Required',
          'To download files and images, this app needs permission to access your device storage.',
        );
        
        if (!shouldRequest) return false;
        
        storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) return true;
      } else {
        return true;
      }

      // If storage permission failed or was denied, try with manage external storage
      // (needed for some devices and Android versions)
      var externalStorageStatus = await Permission.manageExternalStorage.status;
      if (!externalStorageStatus.isGranted) {
        // Show explanation dialog before requesting permission
        final bool shouldRequest = await _showPermissionRationaleDialog(
          context,
          'Storage Access Required',
          'Additional storage permission is needed to download files. This allows the app to save files to your device.',
        );
        
        if (!shouldRequest) return false;
        
        externalStorageStatus = await Permission.manageExternalStorage.request();
        if (externalStorageStatus.isGranted) return true;
      } else {
        return true;
      }

      // If we reach here, permissions were denied
      // Show settings dialog to guide user
      if (context.mounted) {
        await _showPermissionSettingsDialog(context);
      }
      return false;
    } catch (e) {
      debugPrint("Error requesting storage permissions: $e");
      return false;
    }
  }

  // Show a dialog explaining why we need the permission before requesting it
  static Future<bool> _showPermissionRationaleDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    if (!context.mounted) return false;
    
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  // Show a dialog to guide the user to app settings when permissions are denied
  static Future<void> _showPermissionSettingsDialog(BuildContext context) async {
    if (!context.mounted) return;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Storage permission is required to download files. Please enable it in app settings.',
          ),
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
