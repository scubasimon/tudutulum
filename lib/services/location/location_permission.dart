import 'package:permission_handler/permission_handler.dart';

class PermissionLocation {
  static final PermissionLocation _singleton = PermissionLocation._internal();

  factory PermissionLocation() {
    return _singleton;
  }
  PermissionLocation._internal();

  Future<bool> permission() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.location].request();
    if (statuses[Permission.location] != null) {
      if (statuses[Permission.location]!.isPermanentlyDenied) {
        return false;
      } else {
        if (statuses[Permission.location]!.isDenied || statuses[Permission.location]!.isRestricted) {
          return false;
        } else {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> permissionAlways() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.location].request();
    if (statuses[Permission.locationAlways] != null) {
      if (statuses[Permission.locationAlways]!.isPermanentlyDenied) {
        return false;
      } else {
        if (statuses[Permission.locationAlways]!.isDenied || statuses[Permission.location]!.isRestricted) {
          return false;
        } else {
          return true;
        }
      }
    }
    return false;
  }
}