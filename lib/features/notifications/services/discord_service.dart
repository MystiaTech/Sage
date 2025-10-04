import 'dart:convert';
import 'package:http/http.dart' as http;

class DiscordService {
  String? webhookUrl;

  /// Send a notification to Discord
  Future<bool> sendNotification({
    required String title,
    required String message,
    String? imageUrl,
  }) async {
    if (webhookUrl == null || webhookUrl!.isEmpty) {
      print('Discord webhook URL not configured');
      return false;
    }

    try {
      final embed = {
        'title': title,
        'description': message,
        'color': 0x4CAF50, // Sage green (hex color)
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (imageUrl != null) {
        embed['thumbnail'] = {'url': imageUrl};
      }

      final response = await http.post(
        Uri.parse(webhookUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'embeds': [embed],
        }),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error sending Discord notification: $e');
      return false;
    }
  }

  /// Send expiration alert
  Future<void> sendExpirationAlert({
    required String itemName,
    required int daysUntilExpiration,
  }) async {
    String emoji = '⚠️';
    String urgency = 'Warning';

    if (daysUntilExpiration <= 0) {
      emoji = '🚨';
      urgency = 'Expired';
    } else if (daysUntilExpiration <= 3) {
      emoji = '⚠️';
      urgency = 'Critical';
    }

    await sendNotification(
      title: '$emoji Food Expiration Alert - $urgency',
      message: daysUntilExpiration <= 0
          ? '**$itemName** has expired!'
          : '**$itemName** expires in $daysUntilExpiration day${daysUntilExpiration == 1 ? '' : 's'}!',
    );
  }
}
