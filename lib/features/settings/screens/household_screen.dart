import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../data/local/hive_database.dart';
import '../../household/services/firebase_household_service.dart';
import '../models/app_settings.dart';
import '../models/household.dart';

class HouseholdScreen extends StatefulWidget {
  const HouseholdScreen({super.key});

  @override
  State<HouseholdScreen> createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends State<HouseholdScreen> {
  final _firebaseService = FirebaseHouseholdService();
  AppSettings? _settings;
  Household? _household;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final settings = await HiveDatabase.getSettings();
    Household? household;

    if (settings.currentHouseholdId != null) {
      try {
        // Load from Firebase
        household = await _firebaseService.getHousehold(settings.currentHouseholdId!);
      } catch (e) {
        // Household not found
      }
    }

    setState(() {
      _settings = settings;
      _household = household;
      _isLoading = false;
    });
  }

  Future<void> _createHousehold() async {
    if (_settings!.userName == null || _settings!.userName!.isEmpty) {
      _showNameInputDialog();
      return;
    }

    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Household'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Household Name',
                hintText: 'e.g., Smith Family, Roommates',
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        // Create household in Firebase
        final household = await _firebaseService.createHousehold(result, _settings!.userName!);

        // Also save to local Hive for offline access
        await HiveDatabase.saveHousehold(household);

        _settings!.currentHouseholdId = household.id;
        await _settings!.save();

        await _loadData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Household created! Code: ${household.id}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating household: ${e.toString().contains('firebase') ? 'Firebase not configured. See FIREBASE_SETUP.md' : e.toString()}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _joinHousehold() async {
    if (_settings!.userName == null || _settings!.userName!.isEmpty) {
      _showNameInputDialog();
      return;
    }

    final codeController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Household'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the household code shared with you:'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Household Code',
                hintText: '6-character code',
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, codeController.text),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final code = result.toUpperCase();

        // Join household in Firebase
        final success = await _firebaseService.joinHousehold(code, _settings!.userName!);

        if (success) {
          // Load the household data
          final household = await _firebaseService.getHousehold(code);

          if (household != null) {
            // Save to local Hive for offline access
            await HiveDatabase.saveHousehold(household);

            _settings!.currentHouseholdId = household.id;
            await _settings!.save();

            await _loadData();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Joined ${household.name}!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Household not found. Check the code and try again.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error joining household: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _showNameInputDialog() async {
    final nameController = TextEditingController(text: _settings!.userName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Your Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your name to use household sharing:'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'e.g., Sarah',
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      _settings!.userName = result;
      await _settings!.save();
      setState(() {});
    }
  }

  Future<void> _leaveHousehold() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Household?'),
        content: const Text(
          'You will no longer see items from this household. You can rejoin later with the household code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Leave',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && _household != null) {
      // Leave household in Firebase
      await _firebaseService.leaveHousehold(_household!.id, _settings!.userName!);

      _settings!.currentHouseholdId = null;
      await _settings!.save();

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Left household'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Sharing'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _household == null ? _buildNoHousehold() : _buildHouseholdInfo(),
    );
  }

  Widget _buildNoHousehold() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.group,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          const Text(
            'Share Your Inventory',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Create or join a household to share your kitchen inventory with family or roommates!',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createHousehold,
              icon: const Icon(Icons.add),
              label: const Text('Create Household'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _joinHousehold,
              icon: const Icon(Icons.login),
              label: const Text('Join Household'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseholdInfo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.home, color: AppColors.primary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _household!.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Owner: ${_household!.ownerName}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                const Text(
                  'Household Code',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _household!.id,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _household!.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share this code with others to let them join your household',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Members',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._household!.members.map((member) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    member[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(member),
                trailing: member == _household!.ownerName
                    ? const Chip(
                        label: Text('Owner'),
                        backgroundColor: AppColors.primary,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : null,
              ),
            )),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _leaveHousehold,
          icon: const Icon(Icons.exit_to_app),
          label: const Text('Leave Household'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
