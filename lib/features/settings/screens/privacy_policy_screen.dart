import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Sage - Kitchen Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last Updated: October 4, 2025',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          _buildSection(
            'Data Collection',
            'Sage is designed with your privacy in mind. All your data is stored locally on your device. We do not collect, transmit, or sell any personal information.',
          ),

          _buildSection(
            'Local Storage',
            'Your inventory data, settings, and preferences are stored locally using Hive database. This data never leaves your device unless you explicitly choose to export it.',
          ),

          _buildSection(
            'Camera Permissions',
            'The app requests camera permission only for barcode scanning functionality. No photos or videos are stored or transmitted.',
          ),

          _buildSection(
            'Internet Access',
            'The app uses internet connection to:\n• Look up product information from public databases (Open Food Facts, UPCItemDB)\n• Send Discord notifications (only if you configure webhook)\n\nNo personal data is sent to these services except the barcode number for product lookup.',
          ),

          _buildSection(
            'Discord Integration',
            'If you enable Discord notifications, you provide your own webhook URL. Notifications are sent directly from your device to your Discord server. We do not have access to or store your webhook URL on any server.',
          ),

          _buildSection(
            'Third-Party Services',
            'The app may use the following third-party services:\n• Open Food Facts API - for product information\n• UPCItemDB API - for product information\n\nPlease review their respective privacy policies.',
          ),

          _buildSection(
            'Data Security',
            'Your data is stored locally on your device and protected by your device\'s security measures. We recommend keeping your device secured with a password or biometric lock.',
          ),

          _buildSection(
            'Children\'s Privacy',
            'Sage does not knowingly collect any information from children under 13. The app is designed for general household use.',
          ),

          _buildSection(
            'Changes to Privacy Policy',
            'We may update this privacy policy from time to time. Any changes will be reflected in the app with an updated "Last Updated" date.',
          ),

          _buildSection(
            'Contact Us',
            'If you have questions about this privacy policy, please open an issue on our GitHub repository or contact us through the app store.',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
