// Can be generated automatically
import 'package:hive/hive.dart';

part 'user_adapater.g.dart';

// run flutter packages pub run build_runner build to generate a new adpater
@HiveType(typeId: 1)
class User {
  @HiveField(0)
  String name;
  @HiveField(1)
  String email;
  @HiveField(2)
  int expires;

  User(this.name, this.email, this.expires);

  DateTime getExpirey() {
    return DateTime.fromMillisecondsSinceEpoch(expires);
  }

  @override
  String toString() => "$name valid until ${getExpirey()}"; // Just for print()
}
