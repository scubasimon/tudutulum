import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:tudu/generated/l10n.dart';

class PermissionRequest {
  static bool isResquestPermission = false;

  permissionStartMissionCall(BuildContext context, Function callback) async {
    if (isResquestPermission) {
      isResquestPermission = false;
      await permissionServices(context, callback).then(
        (value) {
          if (value[Permission.location] != null) {
            if (value[Permission.location]!.isGranted) {}
          }
        },
      );
    }
  }

  permissionServiceCall(BuildContext context, Function callback) async {
    if (isResquestPermission) {
      isResquestPermission = false;
      await permissionServices(context, callback).then(
        (value) {
          if (value[Permission.location] != null) {
            if (value[Permission.location]!.isGranted) {
              callback();
            }
          }
        },
      );
    }
  }

  /*Permission services*/
  Future<Map<Permission, PermissionStatus>> permissionServices(BuildContext context, Function callback) async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [Permission.location].request();
    if (statuses[Permission.location] != null) {
      if (statuses[Permission.location]!.isPermanentlyDenied) {
        showDialogLocationSettings(context, callback);
      } else {
        if (statuses[Permission.location]!.isDenied) {
          permissionServiceCall(context, callback);
        }
      }
    }
    return statuses;
  }

  void showDialogLocationSettings(BuildContext context, callback) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(S.current.error),
        content: Text(S.current.location_permission_message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () {

              Navigator.pop(context);
            },
            child: Text(S.current.cancel),
          ),
          CupertinoDialogAction(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text(S.current.open_setting),
          )
        ],
      ),
    );
  }
}
