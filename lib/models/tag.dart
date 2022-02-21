import 'package:flutter_tagging/flutter_tagging.dart';

/// Language Class
class VideoTag extends Taggable {
  ///
  ///
  final int id;
  final String name;
  final String description;

  /// Creates Language
  VideoTag({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object> get props => [name];

  /// Converts the class to json string.
  String toJson() => '''  {
    "name": $name,\n
    "description": $description,\n
    "id": $id\n
  }''';
}
