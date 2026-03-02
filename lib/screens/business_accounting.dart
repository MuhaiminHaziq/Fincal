import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/header.dart';
import '../widgets/document_scanner.dart';
import '../providers/auth_provider.dart';

class BusinessAccountingScreen extends StatefulWidget {
  const BusinessAccountingScreen({super.key});

  @override
  State<BusinessAccountingScreen> createState() =>
      _BusinessAccountingScreenState();
}

class _BusinessAccountingScreenState extends State<BusinessAccountingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();

  // Trading Account fields
  final _salesController = TextEditingController();
  final _salesReturnController = TextEditingController();
  final _openingInventoryController = TextEditingController();
  final _purchasesController = TextEditingController();
  final _purchasesReturnController = TextEditingController(); // Added
  final _closingInventoryController = TextEditingController();

  // Cost of Sales items for Trading Account
  List<Map<String, TextEditingController>> _costOfSalesItems = []; // Added

  // P&L fields (revenues and expenses)
  List<Map<String, TextEditingController>> _revenueItems = [];
  List<Map<String, TextEditingController>> _expenseItems = [];

  // Financial Position fields
  final _openingCapitalController = TextEditingController();
  final _drawingsController = TextEditingController();
  List<Map<String, TextEditingController>> _nonCurrentAssets = [];
  List<Map<String, TextEditingController>> _currentAssets = [];
  List<Map<String, TextEditingController>> _currentLiabilities = [];
  List<Map<String, TextEditingController>> _nonCurrentLiabilities = [];

  DateTime? _selectedDate;
  bool _useRegisteredCompany = true;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _companyNameController.text = authProvider.user?.companyName ?? '';
    }

    // Initialize basic trading account fields with specified values
    _salesController.text = '13100';
    _salesReturnController.text = '420';
    _openingInventoryController.text = '990';
    _purchasesController.text = '8450';
    _purchasesReturnController.text = '230';
    _closingInventoryController.text = '1360';

    // Initialize P&L fields with specified values
    _openingCapitalController.text = '10000';
    _drawingsController.text = '450';

    // Initialize cost of sales items with specified amounts
    _costOfSalesItems = [
      {
        'type': TextEditingController(text: 'Service Tax'),
        'amount': TextEditingController(text: '1350'),
      },
      {
        'type': TextEditingController(text: 'Carriage Inwards'),
        'amount': TextEditingController(text: '1130'),
      },
    ];

    // Initialize revenue items with specified amounts
    _revenueItems = [
      {
        'type': TextEditingController(text: 'Discount Received'),
        'amount': TextEditingController(text: '150'),
      },
      {
        'type': TextEditingController(text: 'Interest Received'),
        'amount': TextEditingController(text: '80'),
      },
    ];

    // Initialize expense items with specified amounts
    _expenseItems = [
      {
        'type': TextEditingController(text: 'Discount Allowed'),
        'amount': TextEditingController(text: '260'),
      },
      {
        'type': TextEditingController(text: 'Insurance'),
        'amount': TextEditingController(text: '240'),
      },
      {
        'type': TextEditingController(text: 'Salary'),
        'amount': TextEditingController(text: '1140'),
      },
      {
        'type': TextEditingController(text: 'Carriage Outward'),
        'amount': TextEditingController(text: '150'),
      },
      {
        'type': TextEditingController(text: 'Rent'),
        'amount': TextEditingController(text: '420'),
      },
      {
        'type': TextEditingController(text: 'Rates and Fees'),
        'amount': TextEditingController(text: '120'),
      },
    ];

    // Initialize non-current assets with specified amounts
    _nonCurrentAssets = [
      {
        'type': TextEditingController(text: 'Building'),
        'amount': TextEditingController(text: '5400'),
      },
      {
        'type': TextEditingController(text: 'Furniture'),
        'amount': TextEditingController(text: '650'),
      },
      {
        'type': TextEditingController(text: 'Vehicle'),
        'amount': TextEditingController(text: '4000'),
      },
    ];

    // Initialize current assets with specified amounts
    _currentAssets = [
      {
        'type': TextEditingController(text: 'Inventory'),
        'amount': TextEditingController(text: '1360'),
      },
      {
        'type': TextEditingController(text: 'Accounts Receivable'),
        'amount': TextEditingController(text: '2250'),
      },
      {
        'type': TextEditingController(text: 'Bank'),
        'amount': TextEditingController(text: '1430'),
      },
    ];

    // Initialize current liabilities with specified amounts
    _currentLiabilities = [
      {
        'type': TextEditingController(text: 'Accounts Payable'),
        'amount': TextEditingController(text: '2290'),
      },
    ];

    // Initialize non-current liabilities with specified amounts
    _nonCurrentLiabilities = [
      {
        'type': TextEditingController(text: 'Long Term Loan'),
        'amount': TextEditingController(text: '3000'),
      },
    ];
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _salesController.dispose();
    _salesReturnController.dispose();
    _openingInventoryController.dispose();
    _purchasesController.dispose();
    _purchasesReturnController.dispose(); // Added
    _closingInventoryController.dispose();
    _openingCapitalController.dispose();
    _drawingsController.dispose();

    // Dispose dynamic items
    for (final list in [
      _costOfSalesItems,
      _revenueItems,
      _expenseItems,
      _nonCurrentAssets,
      _currentAssets,
      _currentLiabilities,
      _nonCurrentLiabilities,
    ]) {
      for (final item in list) {
        item['type']?.dispose();
        item['amount']?.dispose();
      }
    }

    super.dispose();
  }

  void _addItem(List<Map<String, TextEditingController>> items) {
    setState(() {
      items.add({
        'type': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _removeItem(List<Map<String, TextEditingController>> items, int index) {
    if (items.length > 1) {
      setState(() {
        items[index]['type']?.dispose();
        items[index]['amount']?.dispose();
        items.removeAt(index);
      });
    }
  }

  void _handleReset() {
    _salesController.clear();
    _salesReturnController.clear();
    _openingInventoryController.clear();
    _purchasesController.clear();
    _purchasesReturnController.clear(); // Added
    _closingInventoryController.clear();
    _openingCapitalController.clear();
    _drawingsController.clear();

    for (final list in [
      _costOfSalesItems,
      _revenueItems,
      _expenseItems,
      _nonCurrentAssets,
      _currentAssets,
      _currentLiabilities,
      _nonCurrentLiabilities,
    ]) {
      for (final item in list) {
        item['amount']?.clear();
      }
    }

    setState(() {
      _selectedDate = null;
    });
  }

  void _handleCalculate() {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final companyName = _useRegisteredCompany
        ? (authProvider.user?.companyName ?? 'Unknown Company')
        : _companyNameController.text.trim();

    final data = {
      'companyName': companyName,
      'sales': _salesController.text,
      'salesReturn': _salesReturnController.text,
      'openingInventory': _openingInventoryController.text,
      'purchases': _purchasesController.text,
      'purchasesReturn': _purchasesReturnController.text,
      'closingInventory': _closingInventoryController.text,
      'costOfSales': _filterItems(_costOfSalesItems),
      'revenues': _filterItems(_revenueItems),
      'expenses': _filterItems(_expenseItems),
      'openingCapital': _openingCapitalController.text,
      'drawings': _drawingsController.text,
      'nonCurrentAssets': _filterItems(_nonCurrentAssets),
      'currentAssets': _filterItems(_currentAssets),
      'currentLiabilities': _filterItems(_currentLiabilities),
      'nonCurrentLiabilities': _filterItems(_nonCurrentLiabilities),
      'date': _selectedDate ?? DateTime.now(),
    };

    Navigator.pushNamed(
      context,
      '/business-accounting-result',
      arguments: data,
    );
  }

  void _handleScanComplete(Map<String, String> extractedData) {
    setState(() {
      // Auto-fill trading account fields
      if (extractedData.containsKey('sales')) {
        _salesController.text = extractedData['sales']!;
      }
      if (extractedData.containsKey('purchases')) {
        _purchasesController.text = extractedData['purchases']!;
      }
      if (extractedData.containsKey('inventory')) {
        _openingInventoryController.text = extractedData['inventory']!;
      }
      if (extractedData.containsKey('openingCapital')) {
        _openingCapitalController.text = extractedData['openingCapital']!;
      }
      if (extractedData.containsKey('drawings')) {
        _drawingsController.text = extractedData['drawings']!;
      }

      // Clear and rebuild cost of sales items
      _costOfSalesItems.clear();
      final costOfSalesTypes = {
        'serviceTax': 'Service Tax',
        'carriageInwards': 'Carriage Inwards',
        'insurance': 'Insurance',
        'wages': 'Wages on Purchases',
      };

      costOfSalesTypes.forEach((key, label) {
        if (extractedData.containsKey(key)) {
          _costOfSalesItems.add({
            'type': TextEditingController(text: label),
            'amount': TextEditingController(text: extractedData[key]!),
          });
        }
      });

      // If no cost of sales items found, keep at least one empty row
      if (_costOfSalesItems.isEmpty) {
        _costOfSalesItems.add({
          'type': TextEditingController(),
          'amount': TextEditingController(),
        });
      }

      // Clear and rebuild revenue items
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

      // Clear and rebuild expense items
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

      // Clear and rebuild asset items
      _nonCurrentAssets.clear();
      final nonCurrentAssetTypes = {
        'equipment': 'Office Equipment',
        'furniture': 'Furniture',
        'building': 'Building',
        'land': 'Land',
        'vehicle': 'Vehicle',
      };

      nonCurrentAssetTypes.forEach((key, label) {
        if (extractedData.containsKey(key)) {
          _nonCurrentAssets.add({
            'type': TextEditingController(text: label),
            'amount': TextEditingController(text: extractedData[key]!),
          });
        }
      });

      if (_nonCurrentAssets.isEmpty) {
        _nonCurrentAssets.add({
          'type': TextEditingController(),
          'amount': TextEditingController(),
        });
      }

      _currentAssets.clear();
      final currentAssetTypes = {
        'inventory': 'Inventory',
        'receivable': 'Accounts Receivable',
        'bank': 'Bank',
        'cash': 'Cash',
      };

      currentAssetTypes.forEach((key, label) {
        if (extractedData.containsKey(key)) {
          _currentAssets.add({
            'type': TextEditingController(text: label),
            'amount': TextEditingController(text: extractedData[key]!),
          });
        }
      });

      if (_currentAssets.isEmpty) {
        _currentAssets.add({
          'type': TextEditingController(),
          'amount': TextEditingController(),
        });
      }

      // Clear and rebuild liability items
      _currentLiabilities.clear();
      final currentLiabilityTypes = {'payable': 'Accounts Payable'};

      currentLiabilityTypes.forEach((key, label) {
        if (extractedData.containsKey(key)) {
          _currentLiabilities.add({
            'type': TextEditingController(text: label),
            'amount': TextEditingController(text: extractedData[key]!),
          });
        }
      });

      if (_currentLiabilities.isEmpty) {
        _currentLiabilities.add({
          'type': TextEditingController(),
          'amount': TextEditingController(),
        });
      }

      _nonCurrentLiabilities.clear();
      final nonCurrentLiabilityTypes = {
        'loan': 'Long Term Loan',
        'mortgage': 'Mortgage',
      };

      nonCurrentLiabilityTypes.forEach((key, label) {
        if (extractedData.containsKey(key)) {
          _nonCurrentLiabilities.add({
            'type': TextEditingController(text: label),
            'amount': TextEditingController(text: extractedData[key]!),
          });
        }
      });

      if (_nonCurrentLiabilities.isEmpty) {
        _nonCurrentLiabilities.add({
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

  List<Map<String, String>> _filterItems(
    List<Map<String, TextEditingController>> items,
  ) {
    return items
        .where(
          (item) =>
              item['type']?.text.isNotEmpty == true &&
              item['amount']?.text.isNotEmpty == true,
        )
        .map(
          (item) => {
            'type': item['type']?.text ?? '',
            'amount': item['amount']?.text ?? '',
          },
        )
        .toList();
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
                  const Center(
                    child: Text(
                      'Business Accounting',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 32),

                  // Company Section
                  _buildCompanySection(),
                  const SizedBox(height: 24),

                  // Trading Account Data
                  const Text(
                    'Trading Account Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5A84),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'Sales',
                    _salesController,
                    'RM 13 100',
                    defaultValue: '13100',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Sales Return',
                    _salesReturnController,
                    'RM 420',
                    defaultValue: '420',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Opening Inventory',
                    _openingInventoryController,
                    'RM 980',
                    defaultValue: '980',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Purchases',
                    _purchasesController,
                    'RM 8 450',
                    defaultValue: '8450',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Purchases Return',
                    _purchasesReturnController,
                    'RM 230',
                    defaultValue: '230',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Closing Inventory',
                    _closingInventoryController,
                    'RM 1 360',
                    defaultValue: '1360',
                  ),
                  const SizedBox(height: 24),

                  // Cost of Sales Section - Added
                  _buildDynamicSection('Cost of Sales (+)', _costOfSalesItems, [
                    'Service Tax',
                    'Carriage Inwards',
                    'Wages on Purchases',
                    'Insurance',
                    'Other Cost',
                  ]),

                  // Income Statement Data
                  const Text(
                    'Income Statement Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5A84),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDynamicSection('Revenue Items', _revenueItems, [
                    'Discount Received',
                    'Interest Received',
                    'Commission Received',
                    'Rental Income',
                    'Custom Item',
                  ], allowCustom: true),

                  _buildDynamicSection('Expense Items', _expenseItems, [
                    'Discount Allowed',
                    'Rent',
                    'Employee Salary',
                    'Depreciation Expense',
                    'Custom Item',
                  ], allowCustom: true),

                  // Financial Position Data
                  const Text(
                    'Financial Position Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5A84),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'Opening Capital',
                    _openingCapitalController,
                    'RM 21 000',
                    defaultValue: '21000',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Drawings',
                    _drawingsController,
                    'RM 1 200',
                    defaultValue: '1200',
                  ),
                  const SizedBox(height: 24),

                  _buildDynamicSection(
                    'Non-Current Assets',
                    _nonCurrentAssets,
                    [
                      'Office Equipment',
                      'Furniture',
                      'Building',
                      'Land',
                      'Vehicle',
                    ],
                  ),

                  _buildDynamicSection('Current Assets', _currentAssets, [
                    'Inventory',
                    'Accounts Receivable',
                    'Bank',
                    'Cash',
                    'Prepaid Expenses',
                  ]),

                  _buildDynamicSection(
                    'Current Liabilities',
                    _currentLiabilities,
                    [
                      'Accounts Payable',
                      'Notes Payable',
                      'Accrued Expenses',
                      'Short Term Loan',
                    ],
                  ),

                  _buildDynamicSection(
                    'Non-Current Liabilities',
                    _nonCurrentLiabilities,
                    ['Long Term Loan', 'Mortgage', 'Bonds Payable'],
                  ),

                  // Date picker
                  _buildDatePicker(),

                  const SizedBox(height: 24),

                  // Document Scanner
                  DocumentScanner(onScanComplete: _handleScanComplete),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleReset,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF8B5A84)),
                            foregroundColor: const Color(0xFF8B5A84),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleCalculate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5A84),
                            foregroundColor: Colors.white,
                          ),
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

  Widget _buildCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _useRegisteredCompany,
              onChanged: (value) {
                setState(() {
                  _useRegisteredCompany = value ?? true;
                  if (_useRegisteredCompany) {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    if (authProvider.user != null) {
                      _companyNameController.text =
                          authProvider.user?.companyName ?? '';
                    }
                  }
                });
              },
              activeColor: const Color(0xFF8B5A84),
            ),
            const Text('Use registered company'),
          ],
        ),
        if (!_useRegisteredCompany) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Custom Company Name',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (!_useRegisteredCompany && (value == null || value.isEmpty)) {
                return 'Please enter company name';
              }
              return null;
            },
          ),
        ],
      ],
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

  Widget _buildDynamicSection(
    String title,
    List<Map<String, TextEditingController>> items,
    List<String> options, {
    bool allowCustom = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            IconButton(
              onPressed: () => _addItem(items),
              icon: const Icon(Icons.add_circle_outline),
              color: const Color(0xFF8B5A84),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: allowCustom && item['type']!.text == 'Custom Item'
                      ? TextFormField(
                          controller: item['type'],
                          decoration: const InputDecoration(
                            hintText: 'Enter custom item name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            isDense: true,
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value:
                              item['type']!.text.isNotEmpty &&
                                  options.contains(item['type']!.text)
                              ? item['type']!.text
                              : null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            isDense: true,
                          ),
                          items: options.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              item['type']!.text = newValue ?? '';
                            });
                          },
                        ),
                ),
                const SizedBox(width: 8),
                const Text(':'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: item['amount'],
                    decoration: const InputDecoration(
                      hintText: 'RM 1 350',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                if (items.length > 1)
                  IconButton(
                    onPressed: () => _removeItem(items, index),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date chooser label',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                      : '31/12/2025',
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
