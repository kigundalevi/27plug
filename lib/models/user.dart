class User {
  final int id;
  final String first_name;
  final String last_name;
  final String email;
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
      this.logged_in = false,
      this.token = '',
      this.dp_url =
          'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png', //put default image url here
      this.user_type = 'plug',
      this.user_type_id = 3});

  @override
  List<Object> get props => [id];
}
