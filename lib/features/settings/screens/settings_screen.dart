import 'package:flutter/material.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_icon.dart';
import '../../../data/local/hive_database.dart';
import '../models/app_settings.dart';
import '../../notifications/services/discord_service.dart';
import '../../inventory/repositories/inventory_repository_impl.dart';
import '../../inventory/models/food_item.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'household_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _discordService = DiscordService();
  AppSettings? _settings;
  bool _isLoading = true;
  String _appVersion = '1.3.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
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

          // Sharing Section
          _buildSectionHeader('Sharing'),
          ListTile(
            title: const Text('Household Sharing'),
            subtitle: Text(_settings!.currentHouseholdId != null
                ? 'Connected to household'
                : 'Share inventory with family'),
            leading: const Icon(Icons.group, color: AppColors.primary),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HouseholdScreen(),
                ),
              );
              // Reload settings after returning from household screen
              _loadSettings();
            },
          ),

          const Divider(),

          // Display Section
          _buildSectionHeader('Display'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Reduce eye strain with dark theme'),
            value: _settings!.darkModeEnabled,
            onChanged: (value) {
              setState(() => _settings!.darkModeEnabled = value);
              _saveSettings();
            },
            activeColor: AppColors.primary,
          ),
          ListTile(
            title: const Text('Default View'),
            subtitle: Text(_settings!.defaultView == 'grid' ? 'Grid' : 'List'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showDefaultViewDialog,
          ),
          ListTile(
            title: const Text('Sort By'),
            subtitle: Text(_getSortByDisplayName(_settings!.sortBy)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showSortByDialog,
          ),

          const Divider(),

          // Data Section
          _buildSectionHeader('Data'),
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Export your inventory to CSV'),
            leading: const Icon(Icons.file_download, color: AppColors.primary),
            onTap: _exportData,
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
                      onPressed: () async {
                        // Clear all data from Hive
                        await HiveDatabase.clearAllData();

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All data cleared successfully'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
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
          ListTile(
            title: const Text('Version'),
            subtitle: Text(_appVersion),
          ),
          const ListTile(
            title: Text('Developer'),
            subtitle: Text('Danielle Sapelli'),
          ),
          const ListTile(
            title: Text('Built With'),
            subtitle: Text('❤️ using Flutter & Claude Code'),
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
                applicationVersion: _appVersion,
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

  Future<void> _exportData() async {
    try {
      final repository = InventoryRepositoryImpl();
      final items = await repository.getAllItems();

      if (items.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No items to export!')),
          );
        }
        return;
      }

      // Create CSV data
      List<List<dynamic>> csvData = [
        ['Name', 'Category', 'Location', 'Quantity', 'Unit', 'Barcode', 'Purchase Date', 'Expiration Date', 'Notes'],
      ];

      for (var item in items) {
        csvData.add([
          item.name,
          item.category ?? '',
          item.location.displayName,
          item.quantity,
          item.unit ?? '',
          item.barcode ?? '',
          DateFormat('yyyy-MM-dd').format(item.purchaseDate),
          DateFormat('yyyy-MM-dd').format(item.expirationDate),
          item.notes ?? '',
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/sage_inventory_$timestamp.csv';
      final file = File(filePath);
      await file.writeAsString(csv);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Sage Inventory Export',
        text: 'Exported ${items.length} items from Sage Kitchen Manager',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${items.length} items!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getSortByDisplayName(String sortBy) {
    switch (sortBy) {
      case 'expiration':
        return 'Expiration Date';
      case 'name':
        return 'Name';
      case 'location':
        return 'Location';
      default:
        return 'Expiration Date';
    }
  }

  Future<void> _showDefaultViewDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default View'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Grid'),
              leading: Radio<String>(
                value: 'grid',
                groupValue: _settings!.defaultView,
                onChanged: (value) => Navigator.pop(context, value),
                activeColor: AppColors.primary,
              ),
              onTap: () => Navigator.pop(context, 'grid'),
            ),
            ListTile(
              title: const Text('List'),
              leading: Radio<String>(
                value: 'list',
                groupValue: _settings!.defaultView,
                onChanged: (value) => Navigator.pop(context, value),
                activeColor: AppColors.primary,
              ),
              onTap: () => Navigator.pop(context, 'list'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _settings!.defaultView = result);
      await _saveSettings();
    }
  }

  Future<void> _showSortByDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Expiration Date'),
              leading: Radio<String>(
                value: 'expiration',
                groupValue: _settings!.sortBy,
                onChanged: (value) => Navigator.pop(context, value),
                activeColor: AppColors.primary,
              ),
              onTap: () => Navigator.pop(context, 'expiration'),
            ),
            ListTile(
              title: const Text('Name'),
              leading: Radio<String>(
                value: 'name',
                groupValue: _settings!.sortBy,
                onChanged: (value) => Navigator.pop(context, value),
                activeColor: AppColors.primary,
              ),
              onTap: () => Navigator.pop(context, 'name'),
            ),
            ListTile(
              title: const Text('Location'),
              leading: Radio<String>(
                value: 'location',
                groupValue: _settings!.sortBy,
                onChanged: (value) => Navigator.pop(context, value),
                activeColor: AppColors.primary,
              ),
              onTap: () => Navigator.pop(context, 'location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _settings!.sortBy = result);
      await _saveSettings();
    }
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
