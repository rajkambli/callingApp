import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestContactPermission(BuildContext context) async {

    PermissionStatus status = await Permission.contacts.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {

      status = await Permission.contacts.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {

        _showPermissionDialog(context);
      }
    } else if (status.isPermanentlyDenied) {

      _showPermissionDialog(context);
    }

    return false;
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Contacts permission is required to access your contacts & call logs '
              'Please enable it in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // Open app settings
              Navigator.of(ctx).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
