import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Service for handling platform permissions
class PermissionService {
  /// Request storage permissions based on platform and OS version
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Android 13 (API 33) and above
      if (androidInfo.version.sdkInt >= 33) {
        final status = await [
          Permission.photos,
          Permission.videos,
        ].request();
        
        return status[Permission.photos] == PermissionStatus.granted ||
               status[Permission.videos] == PermissionStatus.granted;
      } else {
        // Android 12 and below
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    
    // For other platforms (Windows, macOS, Linux, Web), assume true for now
    // as file_picker handles them differently or they don't have the same permission model
    return true;
  }

  /// Check if storage permission is granted
  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        final photos = await Permission.photos.status;
        final videos = await Permission.videos.status;
        return photos.isGranted || videos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted;
    }
    return true;
  }

  /// Open app settings if permission is permanently denied
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
