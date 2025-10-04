import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Sage - Terms of Service',
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
            'Acceptance of Terms',
            'By downloading, installing, or using the Sage app, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.',
          ),

          _buildSection(
            'Use of the App',
            'Sage is a personal kitchen management tool designed to help you track food inventory and reduce waste. You may use the app for personal, non-commercial purposes.',
          ),

          _buildSection(
            'User Responsibilities',
            'You are responsible for:\n• Maintaining the security of your device\n• Ensuring accuracy of data you enter\n• Complying with food safety guidelines\n• Backing up your data if needed\n\nThe app is a tool to assist you - always use your best judgment regarding food safety.',
          ),

          _buildSection(
            'Disclaimer of Warranties',
            'THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND. We do not guarantee:\n• Accuracy of product information from third-party APIs\n• Accuracy of automatically suggested expiration dates\n• Prevention of food spoilage or food-borne illness\n\nAlways check food quality and safety yourself before consumption.',
          ),

          _buildSection(
            'Limitation of Liability',
            'To the maximum extent permitted by law, we shall not be liable for any damages arising from:\n• Use or inability to use the app\n• Food spoilage or food-borne illness\n• Data loss\n• Reliance on expiration date estimates\n\nYou use the app at your own risk.',
          ),

          _buildSection(
            'Third-Party Services',
            'The app uses third-party APIs (Open Food Facts, UPCItemDB) for product information. We are not responsible for the accuracy, availability, or content of these services.',
          ),

          _buildSection(
            'Discord Integration',
            'If you choose to use Discord notifications:\n• You are responsible for your webhook URL security\n• We are not responsible for Discord service availability\n• You must comply with Discord\'s Terms of Service',
          ),

          _buildSection(
            'Intellectual Property',
            'The Sage app and its original content are provided under an open-source license. Third-party services and APIs have their own terms and licenses.',
          ),

          _buildSection(
            'Changes to Terms',
            'We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms.',
          ),

          _buildSection(
            'Termination',
            'You may stop using the app at any time by uninstalling it. Your local data will be removed with the app.',
          ),

          _buildSection(
            'Governing Law',
            'These terms shall be governed by and construed in accordance with applicable local laws.',
          ),

          _buildSection(
            'Contact',
            'For questions about these Terms of Service, please contact us through the app store or GitHub repository.',
          ),

          const SizedBox(height: 16),
          const Text(
            '⚠️ FOOD SAFETY REMINDER',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This app is a tracking tool only. Always inspect food for signs of spoilage, follow proper food safety guidelines, and use your best judgment. When in doubt, throw it out!',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
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
