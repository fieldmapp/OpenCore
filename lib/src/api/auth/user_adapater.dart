import 'package:hive/hive.dart';

part 'user_adapater.g.dart';

/// generate: dart run build_runner watch
@HiveType(typeId: 1)
class User {
  @HiveField(0)
  String name;
  @HiveField(1)
  String email;
  @HiveField(2)
  int expires;

  @HiveField(3)
  String? accessToken;
  @HiveField(4)
  String? refreshToken;

  User(
      this.name, this.email, this.expires, this.accessToken, this.refreshToken);

  DateTime getExpiry() {
    return DateTime.fromMillisecondsSinceEpoch(expires * 1000);
  }

  @override
  String toString() =>
      "$name valid until ${getExpiry()} $accessToken"; // Just for print()
}
