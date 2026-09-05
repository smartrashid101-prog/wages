import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/providers/employee_provider.dart';

class FilterDialog extends ConsumerStatefulWidget {
  final String? selectedEmployeeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String?, DateTime?, DateTime?) onApply;
  final VoidCallback onClear;
  
  const FilterDialog({
    super.key,
    this.selectedEmployeeId,
    this.startDate,
    this.endDate,
    required this.onApply,
    required this.onClear,
  });

  @override
  ConsumerState<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<FilterDialog> {
  String? _selectedEmployeeId;
  DateTime? _startDate;
  DateTime? _endDate;
  
  @override
  void initState() {
    super.initState();
    _selectedEmployeeId = widget.selectedEmployeeId;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }
  
  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeeListProvider);
    
    return AlertDialog(
      title: const Text('Filter Records'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee filter
            const Text(
              'Employee',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            employeesAsync.when(
              data: (employees) {
                return DropdownButtonFormField<String>(
                  initialValue: _selectedEmployeeId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'All Employees',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Employees'),
                    ),
                    ...employees.map((employee) {
                      return DropdownMenuItem(
                        value: employee.id,
                        child: Text(employee.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployeeId = value;
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading employees'),
            ),
            
            const SizedBox(height: 16),
            
            // Date range
            const Text(
              'Date Range',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Start Date',
                      ),
                      child: Text(
                        _startDate != null
                            ? DateFormat('dd MMM yyyy').format(_startDate!)
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'End Date',
                      ),
                      child: Text(
                        _endDate != null
                            ? DateFormat('dd MMM yyyy').format(_endDate!)
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClear();
            Navigator.pop(context);
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_selectedEmployeeId, _startDate, _endDate);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}