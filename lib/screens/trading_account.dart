import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/header.dart';
import '../widgets/document_scanner.dart';
import '../providers/auth_provider.dart';

class TradingAccountScreen extends StatefulWidget {
  const TradingAccountScreen({super.key});

  @override
  State<TradingAccountScreen> createState() => _TradingAccountScreenState();
}

class _TradingAccountScreenState extends State<TradingAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _salesController = TextEditingController();
  final _salesReturnController = TextEditingController();
  final _openingInventoryController = TextEditingController();
  final _purchasesController = TextEditingController();
  final _purchasesReturnController = TextEditingController();
  final _closingInventoryController = TextEditingController();

  DateTime? _selectedDate;
  bool _useRegisteredCompany = true;
  List<Map<String, TextEditingController>> _costOfSalesItems = [];

  @override
  void initState() {
    super.initState();
    _initializeCostOfSalesItems();
    _initializeCompany();
  }

  void _initializeCompany() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _companyNameController.text = authProvider.user!.companyName;
    }
  }

  void _initializeCostOfSalesItems() {
    final items = [
      {'type': 'Service Tax', 'amount': ''},
      {'type': 'Carriage Inwards', 'amount': ''},
      {'type': 'Insurance', 'amount': ''},
      {'type': 'Wages on Purchases', 'amount': ''},
    ];

    _costOfSalesItems = items
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
    _companyNameController.dispose();
    _salesController.dispose();
    _salesReturnController.dispose();
    _openingInventoryController.dispose();
    _purchasesController.dispose();
    _purchasesReturnController.dispose();
    _closingInventoryController.dispose();

    for (final item in _costOfSalesItems) {
      item['type']?.dispose();
      item['amount']?.dispose();
    }

    super.dispose();
  }

  void _addCostOfSalesItem() {
    setState(() {
      _costOfSalesItems.add({
        'type': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _removeCostOfSalesItem(int index) {
    if (_costOfSalesItems.length > 1) {
      setState(() {
        _costOfSalesItems[index]['type']?.dispose();
        _costOfSalesItems[index]['amount']?.dispose();
        _costOfSalesItems.removeAt(index);
      });
    }
  }

  void _handleScanComplete(Map<String, String> extractedData) {
    setState(() {
      // Auto-fill main fields
      if (extractedData.containsKey('sales')) {
        _salesController.text = extractedData['sales']!;
      }
      if (extractedData.containsKey('purchases')) {
        _purchasesController.text = extractedData['purchases']!;
      }
      if (extractedData.containsKey('openingInventory')) {
        _openingInventoryController.text = extractedData['openingInventory']!;
      }
      if (extractedData.containsKey('closingInventory')) {
        _closingInventoryController.text = extractedData['closingInventory']!;
      }
      // Fallback for generic 'inventory' detection
      if (extractedData.containsKey('inventory') &&
          !extractedData.containsKey('openingInventory')) {
        _openingInventoryController.text = extractedData['inventory']!;
      }

      // Clear and rebuild cost of sales items from scanned data
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
    _salesController.clear();
    _salesReturnController.clear();
    _openingInventoryController.clear();
    _purchasesController.clear();
    _purchasesReturnController.clear();
    _closingInventoryController.clear();

    for (final item in _costOfSalesItems) {
      item['amount']?.clear();
    }

    setState(() {
      _selectedDate = null;
    });
  }

  void _handleCalculate() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'companyName': _useRegisteredCompany
          ? (Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).user?.companyName ??
                'Unknown Company')
          : _companyNameController.text.trim(),
      'sales': _salesController.text,
      'salesReturn': _salesReturnController.text,
      'openingInventory': _openingInventoryController.text,
      'purchases': _purchasesController.text,
      'purchasesReturn': _purchasesReturnController.text,
      'closingInventory': _closingInventoryController.text,
      'costOfSales': _costOfSalesItems
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
          .toList(),
      'date': _selectedDate,
    };

    Navigator.pushNamed(context, '/trading-account-result', arguments: data);
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
                      'Trading Account',
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

                  // Basic Fields
                  _buildTextField('Sales', _salesController, 'RM 20 000'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Sales Return',
                    _salesReturnController,
                    'RM 500',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Opening Inventory',
                    _openingInventoryController,
                    'RM 9 000',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Purchases',
                    _purchasesController,
                    'RM 12 000',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Purchases Return',
                    _purchasesReturnController,
                    'RM 100',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Closing Inventory',
                    _closingInventoryController,
                    'RM 10 000',
                  ),
                  const SizedBox(height: 24),

                  // Cost of Sales Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Insert Cost Of Sales (+)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: _addCostOfSalesItem,
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFF8B5A84),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._costOfSalesItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
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
                                items:
                                    [
                                      'Service Tax',
                                      'Carriage Inwards',
                                      'Insurance',
                                      'Wages on Purchases',
                                      'Other Cost',
                                    ].map((String value) {
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
                                decoration: const InputDecoration(
                                  hintText: 'RM 100',
                                  hintStyle: TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 12),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            if (_costOfSalesItems.length > 1)
                              SizedBox(
                                width: 32,
                                child: IconButton(
                                  onPressed: () =>
                                      _removeCostOfSalesItem(index),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 18,
                                  ),
                                  color: Colors.red,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
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
                          authProvider.user!.companyName;
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
}
