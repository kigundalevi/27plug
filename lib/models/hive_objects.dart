import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class HiveUser extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String first_name;

  @HiveField(2)
  late String last_name;

  @HiveField(3)
  late String email;

  @HiveField(4)
  late String token;
}
