class Video {
  final int id;
  final String name;
  final String url;
  final String thumbnail_name;
  final String thumbnail_url;
  final String title;
  final String description;
  final int duration_millisec;
  final bool watch_later;
  final bool favourite;
  final String views;
  final String upload_lapse;
  final String uploaded_by;
  // final String upload_ip;
  // final String upload_lat;
  // final String upload_lng;

  /// Creates Video
  Video({
    required this.id,
    required this.name,
    required this.url,
    required this.thumbnail_name,
    required this.thumbnail_url,
    required this.title,
    required this.description,
    required this.duration_millisec,
    this.watch_later = true,
    this.favourite = false,
    required this.views,
    required this.upload_lapse,
    required this.uploaded_by,
    // required this.upload_ip,
    // required this.upload_lat,
    // required this.upload_lng,
  });

  /// Converts the class to json string.
  // String toJson() => '''  {
  //   "lat": $lat,\n
  //   "lng": $lng\n
  //   "ip": $ip,\n
  //   "name": $name,\n
  // }''';
}
