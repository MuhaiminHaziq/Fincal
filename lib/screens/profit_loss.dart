import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/header.dart';
import '../widgets/document_scanner.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  final _formKey = GlobalKey<FormState>();
  final _grossProfitController = TextEditingController();

  DateTime? _selectedDate;
  List<Map<String, TextEditingController>> _revenueItems = [];
  List<Map<String, TextEditingController>> _expenseItems = [];

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  void _initializeItems() {
    // Initialize revenue items with empty amounts
    final revenueItems = [
      {'type': 'Discount Received', 'amount': ''},
      {'type': 'Interest Received', 'amount': ''},
      {'type': 'Commission Received', 'amount': ''},
    ];

    _revenueItems = revenueItems
        .map(
          (item) => {
            'type': TextEditingController(text: item['type']!),
            'amount': TextEditingController(text: item['amount']!),
          },
        )
        .toList();

    // Initialize expense items with empty amounts
    final expenseItems = [
      {'type': 'Discount Allowed', 'amount': ''},
      {'type': 'Rent', 'amount': ''},
      {'type': 'Employee Salary', 'amount': ''},
      {'type': 'Depreciation Expense', 'amount': ''},
    ];

    _expenseItems = expenseItems
        .map(
          (item) => {
            'type': TextEditingController(text: item['type']!),
            'amount': TextEditingController(text: item['amount']!),
          },
        )
        .toList();
  }

  @override
  void dispose() {
    _grossProfitController.dispose();

    for (final item in _revenueItems) {
      item['type']?.dispose();
      item['amount']?.dispose();
    }

    for (final item in _expenseItems) {
      item['type']?.dispose();
      item['amount']?.dispose();
    }

    super.dispose();
  }

  void _addRevenueItem() {
    setState(() {
      _revenueItems.add({
        'type': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _addExpenseItem() {
    setState(() {
      _expenseItems.add({
        'type': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _removeRevenueItem(int index) {
    if (_revenueItems.length > 1) {
      setState(() {
        _revenueItems[index]['type']?.dispose();
        _revenueItems[index]['amount']?.dispose();
        _revenueItems.removeAt(index);
      });
    }
  }

  void _removeExpenseItem(int index) {
    if (_expenseItems.length > 1) {
      setState(() {
        _expenseItems[index]['type']?.dispose();
        _expenseItems[index]['amount']?.dispose();
        _expenseItems.removeAt(index);
      });
    }
  }

  void _handleScanComplete(Map<String, String> extractedData) {
    setState(() {
      // Auto-fill gross profit
      if (extractedData.containsKey('grossProfit')) {
        _grossProfitController.text = extractedData['grossProfit']!;
      }

      // Clear and rebuild revenue items from scanned data
      _revenueItems.clear();
      final revenueTypes = {
        'discountReceived': 'Discount Received',
        'interestReceived': 'Interest Received',
        'commissionReceived': 'Commission Received',
      };

      revenueTypes.forEach((key, label) {
        if (extractedData.containsKey(key)) {
          _revenueItems.add({
            'type': TextEditingController(text: label),
            'amount': TextEditingController(text: extractedData[key]!),
          });
        }
      });

      // If no revenue items found, keep at least one empty row
      if (_revenueItems.isEmpty) {
        _revenueItems.add({
          'type': TextEditingController(),
          'amount': TextEditingController(),
        });
      }

      // Clear and rebuild expense items from scanned data
      _expenseItems.clear();
      final expenseTypes = {
        'discountAllowed': 'Discount Allowed',
        'rent': 'Rent',
        'salary': 'Employee Salary',
        'depreciation': 'Depreciation Expense',
      };

      expenseTypes.forEach((key, label) {
        if (extractedData.containsKey(key)) {
          _expenseItems.add({
            'type': TextEditingController(text: label),
            'amount': TextEditingController(text: extractedData[key]!),
          });
        }
      });

      // If no expense items found, keep at least one empty row
      if (_expenseItems.isEmpty) {
        _expenseItems.add({
          'type': TextEditingController(),
          'amount': TextEditingController(),
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Document scanned! Found ${extractedData.length} items and updated form.',
        ),
        backgroundColor: const Color(0xFF8B5A84),
      ),
    );
  }

  void _handleReset() {
    _grossProfitController.clear();

    for (final item in _revenueItems) {
      item['amount']?.clear();
    }

    for (final item in _expenseItems) {
      item['amount']?.clear();
    }

    setState(() {
      _selectedDate = null;
    });
  }

  void _handleCalculate() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'grossProfit': _grossProfitController.text,
      'revenues': _revenueItems
          .where(
            (item) =>
                item['type']!.text.isNotEmpty &&
                item['amount']!.text.isNotEmpty,
          )
          .map(
            (item) => {
              'type': item['type']!.text,
              'amount': item['amount']!.text,
            },
          )
          .toList(),
      'expenses': _expenseItems
          .where(
            (item) =>
                item['type']!.text.isNotEmpty &&
                item['amount']!.text.isNotEmpty,
          )
          .map(
            (item) => {
              'type': item['type']!.text,
              'amount': item['amount']!.text,
            },
          )
          .toList(),
      'date': _selectedDate,
    };

    Navigator.pushNamed(context, '/profit-loss-result', arguments: data);
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Center(
                    child: Text(
                      'Profit & Loss Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 32),

                  // Enter Amount Section
                  const Text(
                    'Enter Amount',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),

                  // Gross Profit
                  _buildTextField(
                    'Gross Profit:',
                    _grossProfitController,
                    'RM 28 467',
                    defaultValue: '30000',
                  ),
                  const SizedBox(height: 24),

                  // Revenue Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Insert Revenue (+)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: _addRevenueItem,
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFF8B5A84),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._revenueItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildDynamicItem(item, index, _removeRevenueItem, [
                      'Discount Received',
                      'Interest Received',
                      'Commission Received',
                      'Other Revenue',
                    ], 'RM 230');
                  }),

                  const SizedBox(height: 24),

                  // Expenses Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Insert Expenses (-)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: _addExpenseItem,
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFF8B5A84),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._expenseItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildDynamicItem(item, index, _removeExpenseItem, [
                      'Discount Allowed',
                      'Rent',
                      'Employee Salary',
                      'Depreciation Expense',
                      'Other Expense',
                    ], 'RM 254');
                  }),

                  const SizedBox(height: 24),

                  // Date Picker
                  const Text(
                    'Date chooser label',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDate != null
                                ? DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_selectedDate!)
                                : '31/12/2025',
                            style: TextStyle(
                              color: _selectedDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Document Scanner
                  DocumentScanner(onScanComplete: _handleScanComplete),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleReset,
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleCalculate,
                          child: const Text('Calculate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hintText, {
    String? defaultValue,
  }) {
    if (defaultValue != null && controller.text.isEmpty) {
      controller.text = defaultValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDynamicItem(
    Map<String, TextEditingController> item,
    int index,
    Function(int) removeFunction,
    List<String> dropdownItems,
    String amountHint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: item['type']!.text.isNotEmpty
                    ? item['type']!.text
                    : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                items: dropdownItems.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  item['type']!.text = newValue ?? '';
                },
              ),
            ),
            const SizedBox(width: 4),
            const Text(':', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: item['amount'],
                decoration: InputDecoration(
                  hintText: amountHint,
                  hintStyle: const TextStyle(fontSize: 12),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              width: 32,
              child: IconButton(
                onPressed: () => removeFunction(index),
                icon: const Icon(Icons.remove_circle_outline, size: 18),
                color: Colors.red,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
