import 'package:flutter/material.dart';

// Simple Employee class for the form
class FormEmployee {
  final String id;
  final String userId;
  final String name;
  final int hourlyRateCents;
  final int overtimeRateCents;
  final double overtimeMultiplier;
  final String? notes;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  
  FormEmployee({
    required this.id,
    required this.userId,
    required this.name,
    required this.hourlyRateCents,
    required this.overtimeRateCents,
    required this.overtimeMultiplier,
    this.notes,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}

// Simple Money Utils
class FormMoneyUtils {
  static double centsToPounds(int cents) {
    return cents / 100;
  }
  
  static int poundsToCents(double pounds) {
    return (pounds * 100).round();
  }
  
  static String formatCurrency(int cents, {String currencySymbol = '£'}) {
    final pounds = centsToPounds(cents);
    return '$currencySymbol${pounds.toStringAsFixed(2)}';
  }
}

// Simple Employee Validator
class FormEmployeeValidator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }
}

class EmployeeFormDialog extends StatefulWidget {
  final FormEmployee? initialEmployee;
  final Function(Map<String, dynamic>) onSave;
  
  const EmployeeFormDialog({
    super.key,
    this.initialEmployee,
    required this.onSave,
  });

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _overtimeRateController = TextEditingController();
  final _overtimeMultiplierController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmployee != null) {
      _nameController.text = widget.initialEmployee!.name;
      _hourlyRateController.text = 
          FormMoneyUtils.centsToPounds(widget.initialEmployee!.hourlyRateCents).toStringAsFixed(2);
      _overtimeRateController.text = 
          FormMoneyUtils.centsToPounds(widget.initialEmployee!.overtimeRateCents).toStringAsFixed(2);
      _overtimeMultiplierController.text = 
          widget.initialEmployee!.overtimeMultiplier.toString();
      _notesController.text = widget.initialEmployee!.notes ?? '';
      _isActive = widget.initialEmployee!.active;
    } else {
      _hourlyRateController.text = '12.00';
      _overtimeRateController.text = '18.00';
      _overtimeMultiplierController.text = '1.5';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hourlyRateController.dispose();
    _overtimeRateController.dispose();
    _overtimeMultiplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'name': _nameController.text.trim(),
        'hourlyRateCents': FormMoneyUtils.poundsToCents(
          double.parse(_hourlyRateController.text),
        ),
        'overtimeRateCents': FormMoneyUtils.poundsToCents(
          double.parse(_overtimeRateController.text),
        ),
        'overtimeMultiplier': double.parse(_overtimeMultiplierController.text),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'active': _isActive,
      };
      
      await widget.onSave(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialEmployee == null ? 'Add Employee' : 'Edit Employee',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: FormEmployeeValidator.validateName,
              ),
              const SizedBox(height: 16),
              
              // Hourly Rate
              TextFormField(
                controller: _hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Hourly Rate (£) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_pound),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hourly rate';
                  }
                  try {
                    final rate = double.parse(value);
                    if (rate < 0) return 'Rate cannot be negative';
                    return null;
                  } catch (_) {
                    return 'Invalid rate';
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Overtime Rate
              TextFormField(
                controller: _overtimeRateController,
                decoration: const InputDecoration(
                  labelText: 'Overtime Rate (£) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_pound),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter overtime rate';
                  }
                  try {
                    final rate = double.parse(value);
                    if (rate < 0) return 'Rate cannot be negative';
                    return null;
                  } catch (_) {
                    return 'Invalid rate';
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Overtime Multiplier - ✅ FIXED: Changed Icons.times_one to Icons.calculate
              TextFormField(
                controller: _overtimeMultiplierController,
                decoration: const InputDecoration(
                  labelText: 'Overtime Multiplier *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calculate),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter overtime multiplier';
                  }
                  try {
                    final multiplier = double.parse(value);
                    if (multiplier < 0) return 'Multiplier cannot be negative';
                    return null;
                  } catch (_) {
                    return 'Invalid multiplier';
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Active status
              SwitchListTile(
                title: const Text('Active'),
                subtitle: Text(_isActive ? 'Employee is active' : 'Employee is inactive'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}