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

  @HiveField(5)
  String? userName; // User's name for household sharing

  @HiveField(6)
  String? currentHouseholdId; // ID of the household they're in

  @HiveField(7)
  String? supabaseUrl; // Supabase project URL (can use free tier OR self-hosted!)

  @HiveField(8)
  String? supabaseAnonKey; // Supabase anonymous key (public, safe to store)

  @HiveField(9)
  bool darkModeEnabled; // Dark mode toggle

  AppSettings({
    this.discordWebhookUrl,
    this.expirationAlertsEnabled = true,
    this.discordNotificationsEnabled = false,
    this.defaultView = 'grid',
    this.sortBy = 'expiration',
    this.userName,
    this.currentHouseholdId,
    this.supabaseUrl,
    this.supabaseAnonKey,
    this.darkModeEnabled = false,
  });
}
