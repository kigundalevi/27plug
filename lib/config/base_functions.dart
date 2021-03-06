import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/main.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/models/user.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:simple_s3/simple_s3.dart';

Future<String> uploadFileToS3(File file, String folder) async {
  String? result;
  SimpleS3 _simpleS3 = SimpleS3();
  try {
    result = await _simpleS3.uploadFile(
      file,
      kS3BucketName,
      kS3PoolID,
      AWSRegions.euWest3,
      debugLog: true,
      s3FolderPath: folder,
      accessControl: S3AccessControl.publicRead,
      useTimeStamp: true,
    );

    return result;
  } catch (e) {
    print(e);
    return 'error :' + e.toString();
  }
}

User currentUser() {
  var user = appBox.get("user");

  if (user == null) {
    print("NO LOGGED IN USER FOUND!");
    return User(
      id: 1,
      first_name: "27Plug",
      last_name: "Guest",
      channel_name: "",
      email: "guest@27plug.app",
      liked_videos: [],
      later_videos: [],
      favourited_videos: [],
      subscribed_channels: [],
      subscribers: [],
    );
  } else {
    var user = appBox.get("user");
    String dp_url = txtDefaultDpUrl;
    if (user["dp_url"] != null && user["dp_url"] != "") {
      dp_url = user["dp_url"];
      // print(dp_url);
    }
    // print(user['user_type']);
    return User(
      id: user["id"],
      first_name: user["first_name"],
      last_name: user["last_name"],
      channel_name: user["channel_name"],
      phone_no: user["phoneNo"],
      email: user["email"],
      fb_name: user['fb_name'],
      fb_url: user['fb_url'],
      instagram_name: user['instagram_name'],
      instagram_url: user['instagram_url'],
      dp_url: dp_url,
      logged_in: true,
      user_type: user["user_type"],
      user_type_id: user["user_type_id"],
      liked_videos: user["liked_videos"],
      later_videos: user["later_videos"],
      favourited_videos: user["favourited_videos"],
      subscribed_channels: user["subscribed_channels"],
      subscribers: user[" subscribers"],
    );
  }
}

Future<bool> checkOnline() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    // I am connected to a mobile network.
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    /// I am connected to a wifi network.
    return true;
  } else {
    return false;
  }
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Loc> currentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;
  Loc ip_loc = await _locFromIp();
  // print(ip_loc.name);
  try {
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // print('Location services are disabled.');
      return ip_loc;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // print('Location permissions are denied');

        return ip_loc;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      // print(
      //     'Location permissions are permanently denied, we cannot request permissions.');
      return ip_loc;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position pos = await Geolocator.getCurrentPosition();
    return Loc(
        lat: pos.latitude.toString(),
        lng: pos.longitude.toString(),
        ip: ip_loc.ip,
        name: ip_loc.name,
        live: true);
  } catch (e) {
    print(e);
    return ip_loc;
  }
}

Future<Loc> _locFromIp() async {
  Loc location;

  try {
    http.Response res = await http.get(Uri.parse('http://ip-api.com/json'));
    location = Loc(
        lat: json.decode(res.body)['lat'].toString(),
        lng: json.decode(res.body)['lon'].toString(),
        ip: json.decode(res.body)['query'],
        name: json.decode(res.body)['regionName'] +
            ',' +
            json.decode(res.body)['country']);
    print("IP Lock ready");
    return location;
  } catch (err) {
    print(err);
    print("Error getting Loc from IP");

    location = Loc(lat: "0", lng: "0", ip: "0.0.0.0", name: "unknown");
    return location;
    //handleError
  }
}

// Future<Map> _locFromIp() async {
//   Loc location;
//   var cached_location = appBox.get("cached_location");
//   // print(cached_location);

//   try {
//     if (cached_location == null) {
//       http.Response res = await http.get(Uri.parse('http://ip-api.com/json'));

//       location = Loc(
//           lat: json.decode(res.body)['lat'].toString(),
//           lng: json.decode(res.body)['lon'].toString(),
//           ip: json.decode(res.body)['query'],
//           name: json.decode(res.body)['regionName'] +
//               ',' +
//               json.decode(res.body)['country']);

//       Map<String, String> loc = {
//         "lat": json.decode(res.body)['lat'].toString(),
//         "lng": json.decode(res.body)['lon'].toString(),
//         "ip": json.decode(res.body)['query'],
//         "name": json.decode(res.body)['regionName'] +
//             ',' +
//             json.decode(res.body)['country']
//       };

//       appBox.put('cached_location', loc);
//       return loc;
//     } else {
//       return cached_location;
//     }
//   } catch (err) {
//     // print(err);
//     // print("Error getting Loc from IP");

//     location = Loc(lat: "0", lng: "0", ip: "0.0.0.0", name: "unknown");
//     Map<String, String> loc = {
//       "lat": "0.0",
//       "lng": "0.0",
//       "ip": "0.0.0.0",
//       "name": "unknown"
//     };
//     return loc;
//     //handleError
//   }
// }

Future<Map<String, dynamic>> deviceInfo() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var deviceData = <String, dynamic>{};

  try {
    if (kIsWeb) {
      deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
    } else {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      } else if (Platform.isLinux) {
        deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
      } else if (Platform.isMacOS) {
        deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
      } else if (Platform.isWindows) {
        deviceData = _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
      }
    }
  } on PlatformException {
    deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
  }

  return deviceData;
}

Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'version.securityPatch': build.version.securityPatch,
    'version.sdkInt': build.version.sdkInt,
    'version.release': build.version.release,
    'version.previewSdkInt': build.version.previewSdkInt,
    'version.incremental': build.version.incremental,
    'version.codename': build.version.codename,
    'version.baseOS': build.version.baseOS,
    'board': build.board,
    'bootloader': build.bootloader,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'supported32BitAbis': build.supported32BitAbis,
    'supported64BitAbis': build.supported64BitAbis,
    'supportedAbis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'isPhysicalDevice': build.isPhysicalDevice,
    'androidId': build.androidId,
    'systemFeatures': build.systemFeatures,
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'systemName': data.systemName,
    'systemVersion': data.systemVersion,
    'model': data.model,
    'localizedModel': data.localizedModel,
    'identifierForVendor': data.identifierForVendor,
    'isPhysicalDevice': data.isPhysicalDevice,
    'utsname.sysname:': data.utsname.sysname,
    'utsname.nodename:': data.utsname.nodename,
    'utsname.release:': data.utsname.release,
    'utsname.version:': data.utsname.version,
    'utsname.machine:': data.utsname.machine,
  };
}

Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'version': data.version,
    'id': data.id,
    'idLike': data.idLike,
    'versionCodename': data.versionCodename,
    'versionId': data.versionId,
    'prettyName': data.prettyName,
    'buildId': data.buildId,
    'variant': data.variant,
    'variantId': data.variantId,
    'machineId': data.machineId,
  };
}

Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
  return <String, dynamic>{
    'browserName': describeEnum(data.browserName),
    'appCodeName': data.appCodeName,
    'appName': data.appName,
    'appVersion': data.appVersion,
    'deviceMemory': data.deviceMemory,
    'language': data.language,
    'languages': data.languages,
    'platform': data.platform,
    'product': data.product,
    'productSub': data.productSub,
    'userAgent': data.userAgent,
    'vendor': data.vendor,
    'vendorSub': data.vendorSub,
    'hardwareConcurrency': data.hardwareConcurrency,
    'maxTouchPoints': data.maxTouchPoints,
  };
}

Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
  return <String, dynamic>{
    'computerName': data.computerName,
    'hostName': data.hostName,
    'arch': data.arch,
    'model': data.model,
    'kernelVersion': data.kernelVersion,
    'osRelease': data.osRelease,
    'activeCPUs': data.activeCPUs,
    'memorySize': data.memorySize,
    'cpuFrequency': data.cpuFrequency,
    'systemGUID': data.systemGUID,
  };
}

Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
  return <String, dynamic>{
    'numberOfCores': data.numberOfCores,
    'computerName': data.computerName,
    'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
  };
}
