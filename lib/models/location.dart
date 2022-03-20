class Loc {
  final String lat;
  final String lng;
  final String ip;
  final String name;
  final bool live;

  Loc(
      {required this.lat,
      required this.lng,
      required this.ip,
      required this.name,
      this.live = false});

  /// Converts the class to json string.
  String toJson() => '''  {
    "lat": $lat,\n
    "lng": $lng\n
    "ip": $ip,\n
    "name": $name,\n
  }''';
}
