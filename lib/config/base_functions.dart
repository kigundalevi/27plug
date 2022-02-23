import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:africanplug/models/location.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    // return Future.error('Location services are disabled.');
    print('Location services are disabled.');
    return _locFromIp();
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
      // return Future.error('Location permissions are denied');
      print('Location permissions are denied.');
      return _locFromIp();
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    // return Future.error(
    //     'Location permissions are permanently denied, we cannot request permissions.');
    print(
        'Location permissions are permanently denied, we cannot request permissions.');
    return _locFromIp();
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  Position pos = await Geolocator.getCurrentPosition();
  Loc ipLoc = await _locFromIp();
  return Loc(
      lat: pos.latitude.toString(),
      lng: pos.longitude.toString(),
      ip: ipLoc.ip,
      name: ipLoc.name);
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

    return location;
  } catch (err) {
    print(err);
    print("Error getting Loc from IP");

    location = Loc(lat: "0", lng: "0", ip: "0.0.0.0", name: "unknown");
    return location;
    //handleError
  }
}
