import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  static final permissionGroups = PermissionGroup.values;

  static Future<PermissionStatus> request(
      {PermissionGroup permissionGroup}) async {
    return (await PermissionHandler()
        .requestPermissions([permissionGroup]))[permissionGroup];
  }

  static Future<ServiceStatus> checkService(
      {PermissionGroup permissionGroup}) async {
    return await PermissionHandler().checkServiceStatus(permissionGroup);
  }

  static Future<PermissionStatus> checkPermission(
      {PermissionGroup permissionGroup}) async {
    return await PermissionHandler().checkPermissionStatus(permissionGroup);
  }

  static Future<bool> shouldBeConfirmed(
      {PermissionGroup permissionGroup}) async {
    return await PermissionHandler()
        .shouldShowRequestPermissionRationale(permissionGroup);
  }

  static Future<bool> openAppSettings() async {
    return await PermissionHandler().openAppSettings();
  }
}

requestPermiss() async {
  //请求权限
  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler()
      .requestPermissions([PermissionGroup.location, PermissionGroup.camera]);
  //校验权限
  if (permissions[PermissionGroup.camera] != PermissionStatus.granted) {
    print("无照相权限");
  }
  if (permissions[PermissionGroup.location] != PermissionStatus.granted) {
    print("无定位权限");
  }
}
