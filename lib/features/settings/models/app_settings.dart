import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  String? discordWebhookUrl;

  @HiveField(1)
  bool expirationAlertsEnabled;

  @HiveField(2)
  bool discordNotificationsEnabled;

  @HiveField(3)
  String defaultView; // 'grid' or 'list'

  @HiveField(4)
  String sortBy; // 'expiration', 'name', 'location'

  AppSettings({
    this.discordWebhookUrl,
    this.expirationAlertsEnabled = true,
    this.discordNotificationsEnabled = false,
    this.defaultView = 'grid',
    this.sortBy = 'expiration',
  });
}
