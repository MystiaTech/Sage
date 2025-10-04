import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_icon.dart';
import '../../../data/local/hive_database.dart';
import '../models/app_settings.dart';
import '../../notifications/services/discord_service.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _discordService = DiscordService();
  AppSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await HiveDatabase.getSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
      // Load Discord webhook into service
      if (settings.discordWebhookUrl != null) {
        _discordService.webhookUrl = settings.discordWebhookUrl;
      }
    });
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await _settings!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          const SizedBox(height: 16),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Expiration Alerts'),
            subtitle: const Text('Get notified when items are expiring soon'),
            value: _settings!.expirationAlertsEnabled,
            onChanged: (value) {
              setState(() => _settings!.expirationAlertsEnabled = value);
              _saveSettings();
            },
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Discord Notifications'),
            subtitle: Text(_settings!.discordNotificationsEnabled
              ? 'Enabled - Tap to configure'
              : 'Send alerts to Discord'),
            value: _settings!.discordNotificationsEnabled,
            onChanged: (value) {
              if (value) {
                _showDiscordSetup();
              } else {
                setState(() {
                  _settings!.discordNotificationsEnabled = false;
                  _settings!.discordWebhookUrl = null;
                });
                _saveSettings();
              }
            },
            activeColor: AppColors.primary,
          ),

          const Divider(),

          // Display Section
          _buildSectionHeader('Display'),
          ListTile(
            title: const Text('Default View'),
            subtitle: const Text('Grid'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Sort By'),
            subtitle: const Text('Expiration Date'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),

          // Data Section
          _buildSectionHeader('Data'),
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Export your inventory to CSV'),
            leading: const Icon(Icons.file_download, color: AppColors.primary),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all inventory items'),
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Data?'),
                  content: const Text(
                    'This will permanently delete all your inventory items. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Clear data
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All data cleared'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          const ListTile(
            title: Text('App Name'),
            subtitle: Text('Sage - Kitchen Management'),
          ),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            title: Text('Developer'),
            subtitle: Text('Built with ❤️ using Flutter'),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip, color: AppColors.primary),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description, color: AppColors.primary),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfServiceScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Open Source Licenses'),
            leading: const Icon(Icons.code, color: AppColors.primary),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Sage',
                applicationVersion: '1.0.0',
                applicationIcon: const SageLeafIcon(
                  size: 64,
                  color: AppColors.primary,
                ),
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showDiscordSetup() {
    final webhookController = TextEditingController(
      text: _discordService.webhookUrl ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discord Webhook Setup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To receive Discord notifications:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. Go to your Discord server settings'),
            const Text('2. Go to Integrations → Webhooks'),
            const Text('3. Create a new webhook'),
            const Text('4. Copy the webhook URL'),
            const Text('5. Paste it below:'),
            const SizedBox(height: 16),
            TextField(
              controller: webhookController,
              decoration: const InputDecoration(
                labelText: 'Webhook URL',
                hintText: 'https://discord.com/api/webhooks/...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final webhookUrl = webhookController.text.trim();
              _discordService.webhookUrl = webhookUrl;

              // Test the webhook
              final success = await _discordService.sendNotification(
                title: '✅ Discord Connected!',
                message: 'Sage kitchen management app is now connected to Discord.',
              );

              if (mounted) {
                Navigator.pop(context);

                if (success) {
                  // Save to Hive
                  setState(() {
                    _settings!.discordNotificationsEnabled = true;
                    _settings!.discordWebhookUrl = webhookUrl;
                  });
                  await _saveSettings();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Discord connected! Check your server.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to connect. Check your webhook URL.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Save & Test'),
          ),
        ],
      ),
    );
  }
}
