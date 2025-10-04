import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../models/food_item.dart';
import '../controllers/inventory_controller.dart';
import '../services/barcode_service.dart';
import 'barcode_scanner_screen.dart';

/// Screen for adding a new food item to inventory
class AddItemScreen extends ConsumerStatefulWidget {
  final String? scannedBarcode;

  const AddItemScreen({super.key, this.scannedBarcode});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();

  // Form values
  DateTime _purchaseDate = DateTime.now();
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 7));
  Location _location = Location.fridge;
  String? _category;
  String? _barcode;

  @override
  void initState() {
    super.initState();
    // Pre-populate barcode if scanned and lookup product info
    if (widget.scannedBarcode != null) {
      _barcode = widget.scannedBarcode;
      _lookupProductInfo();
    }
  }

  Future<void> _lookupProductInfo() async {
    if (_barcode == null) return;

    // Show loading
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Looking up product info...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    final productInfo = await BarcodeService.lookupBarcode(_barcode!);

    if (productInfo != null && mounted) {
      setState(() {
        // Auto-fill product name
        _nameController.text = productInfo.name;

        // Auto-fill category
        _category = productInfo.category;

        // Set smart expiration date based on category
        final smartDays = BarcodeService.getSmartExpirationDays(productInfo.category);
        _expirationDate = DateTime.now().add(Duration(days: smartDays));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Auto-filled: ${productInfo.name}'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      // Still keep the barcode, just let user fill in the rest
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product not found in database. Barcode saved: $_barcode'),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isExpiration) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExpiration ? _expirationDate : _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isExpiration) {
          _expirationDate = picked;
        } else {
          _purchaseDate = picked;
        }
      });
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final item = FoodItem()
        ..name = _nameController.text.trim()
        ..barcode = _barcode
        ..quantity = int.tryParse(_quantityController.text) ?? 1
        ..unit = _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim()
        ..purchaseDate = _purchaseDate
        ..expirationDate = _expirationDate
        ..location = _location
        ..category = _category
        ..notes = _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim()
        ..lastModified = DateTime.now();

      try {
        await ref.read(inventoryControllerProvider.notifier).addItem(item);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} added to inventory! 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving item: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'e.g., Milk, Ranch Dressing',
                prefixIcon: Icon(Icons.fastfood),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Barcode Scanner
            OutlinedButton.icon(
              onPressed: () async {
                final barcode = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerScreen(),
                  ),
                );
                if (barcode != null) {
                  setState(() {
                    _barcode = barcode;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Barcode scanned: $barcode'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(_barcode == null ? 'Scan Barcode' : 'Barcode: $_barcode'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity & Unit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'bottles, lbs, oz',
                      prefixIcon: Icon(Icons.scale),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            DropdownButtonFormField<Location>(
              value: _location,
              decoration: const InputDecoration(
                labelText: 'Location *',
                prefixIcon: Icon(Icons.location_on),
              ),
              items: Location.values.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text('${location.emoji} ${location.displayName}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _location = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Category
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Category (Optional)',
                hintText: 'Dairy, Produce, Condiments',
                prefixIcon: Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => _category = value.isEmpty ? null : value,
            ),
            const SizedBox(height: 24),

            // Purchase Date
            ListTile(
              title: const Text('Purchase Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_purchaseDate)),
              leading: const Icon(Icons.shopping_cart, color: AppColors.primary),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 12),

            // Expiration Date
            ListTile(
              title: const Text('Expiration Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_expirationDate)),
              leading: const Icon(Icons.event_busy, color: AppColors.warning2),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any additional details',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton.icon(
              onPressed: _saveItem,
              icon: const Icon(Icons.save),
              label: const Text('Save Item'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
