import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class AppSettings extends HiveObject {
  @HiveField(0)
  String customMessage;

  @HiveField(1)
  bool shakeEnabled;

  @HiveField(2)
  bool locationSharingEnabled;

  @HiveField(3)
  bool notificationsEnabled;

  @HiveField(4)
  bool darkMode;

  AppSettings({
    this.customMessage = 'EMERGENCY ALERT! i need help immediately!',
    this.shakeEnabled = true,
    this.locationSharingEnabled = true,
    this.notificationsEnabled = true,
    this.darkMode = false,
  });
}
