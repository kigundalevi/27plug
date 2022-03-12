import 'package:africanplug/config/config.dart';

class User {
  final int id;
  final String first_name;
  final String last_name;
  final String channel_name;
  final String email;
  final String? fb_name;
  final String? fb_url;
  final String? instagram_name;
  final String? instagram_url;
  final String phone_no;
  final bool logged_in;
  final String token;
  final String dp_url;
  final String user_type;
  final int user_type_id;

  /// Creates Language
  User(
      {required this.id,
      required this.first_name,
      required this.last_name,
      required this.email,
      this.fb_name,
      this.fb_url,
      this.instagram_name,
      this.instagram_url,
      required this.channel_name,
      this.phone_no = '',
      this.logged_in = false,
      this.token = '',
      this.dp_url = txtDefaultDpUrl, //put default image url here
      this.user_type = 'plug',
      this.user_type_id = 3});

  @override
  List<Object> get props => [id];
}
