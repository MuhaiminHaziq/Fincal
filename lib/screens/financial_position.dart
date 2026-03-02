import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/header.dart';
import '../widgets/document_scanner.dart';
import '../providers/auth_provider.dart';

class FinancialPositionScreen extends StatefulWidget {
  const FinancialPositionScreen({super.key});

  @override
  State<FinancialPositionScreen> createState() =>
      _FinancialPositionScreenState();
}

class _FinancialPositionScreenState extends State<FinancialPositionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _netProfitController = TextEditingController();
  final _openingCapitalController = TextEditingController();
  final _drawingsController = TextEditingController();

  DateTime? _selectedDate;
  bool _useRegisteredCompany = true;
  List<Map<String, TextEditingController>> _nonCurrentAssets = [];
  List<Map<String, TextEditingController>> _currentAssets = [];
  List<Map<String, TextEditingController>> _currentLiabilities = [];
  List<Map<String, TextEditingController>> _nonCurrentLiabilities = [];

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  void _initializeItems() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _companyNameController.text = authProvider.user!.companyName;
    }

    // Initialize with empty values
    _netProfitController.text = '';
    _openingCapitalController.text = '';
    _drawingsController.text = '';

    // Non-current assets with empty amounts
    _nonCurrentAssets = [
      {
        'type': TextEditingController(text: 'Office Equipment'),
        'amount': TextEditingController(text: ''),
      },
      {
        'type': TextEditingController(text: 'Furniture'),
        'amount': TextEditingController(text: ''),
      },
    ];

    // Current assets with empty amounts
    _currentAssets = [
      {
        'type': TextEditingController(text: 'Inventory'),
        'amount': TextEditingController(text: ''),
      },
      {
        'type': TextEditingController(text: 'Accounts Receivable'),
        'amount': TextEditingController(text: ''),
      },
      {
        'type': TextEditingController(text: 'Bank'),
        'amount': TextEditingController(text: ''),
      },
    ];

    // Current liabilities with empty amounts
    _currentLiabilities = [
      {
        'type': TextEditingController(text: 'Accounts Payable'),
        'amount': TextEditingController(text: ''),
      },
    ];

    // Non-current liabilities with empty amounts
    _nonCurrentLiabilities = [
      {
        'type': TextEditingController(text: 'Loan'),
        'amount': TextEditingController(text: ''),
      },
    ];
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _netProfitController.dispose();
    _openingCapitalController.dispose();
    _drawingsController.dispose();

    for (final list in [
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

  void _handleScanComplete(Map<String, String> extractedData) {
    setState(() {
      // Auto-fill basic fields
      if (extractedData.containsKey('netProfit')) {
        _netProfitController.text = extractedData['netProfit']!;
      }
      if (extractedData.containsKey('openingCapital')) {
        _openingCapitalController.text = extractedData['openingCapital']!;
      }
      if (extractedData.containsKey('drawings')) {
        _drawingsController.text = extractedData['drawings']!;
      }

      // Clear and rebuild non-current assets from scanned data
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

      // If no non-current assets found, keep at least one empty row
      if (_nonCurrentAssets.isEmpty) {
        _nonCurrentAssets.add({
          'type': TextEditingController(),
          'amount': TextEditingController(),
        });
      }

      // Clear and rebuild current assets from scanned data
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

      // If no current assets found, keep at least one empty row
      if (_currentAssets.isEmpty) {
        _currentAssets.add({
          'type': TextEditingController(),
          'amount': TextEditingController(),
        });
      }

      // Clear and rebuild current liabilities from scanned data
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

      // If no current liabilities found, keep at least one empty row
      if (_currentLiabilities.isEmpty) {
        _currentLiabilities.add({
          'type': TextEditingController(),
          'amount': TextEditingController(),
        });
      }

      // Clear and rebuild non-current liabilities from scanned data
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

      // If no non-current liabilities found, keep at least one empty row
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

  void _handleCalculate() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'companyName': _useRegisteredCompany
          ? Provider.of<AuthProvider>(context, listen: false).user!.companyName
          : _companyNameController.text.trim(),
      'netProfit': _netProfitController.text,
      'openingCapital': _openingCapitalController.text,
      'drawings': _drawingsController.text,
      'nonCurrentAssets': _filterItems(_nonCurrentAssets),
      'currentAssets': _filterItems(_currentAssets),
      'currentLiabilities': _filterItems(_currentLiabilities),
      'nonCurrentLiabilities': _filterItems(_nonCurrentLiabilities),
      'date': _selectedDate ?? DateTime.now(),
    };

    Navigator.pushNamed(context, '/financial-position-result', arguments: data);
  }

  List<Map<String, String>> _filterItems(
    List<Map<String, TextEditingController>> items,
  ) {
    return items
        .where(
          (item) =>
              item['type']!.text.isNotEmpty && item['amount']!.text.isNotEmpty,
        )
        .map(
          (item) => {
            'type': item['type']!.text,
            'amount': item['amount']!.text,
          },
        )
        .toList();
  }

  void _handleReset() {
    _netProfitController.clear();
    _openingCapitalController.clear();
    _drawingsController.clear();

    for (final list in [
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
                      'Statement of financial position',
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

                  // Basic fields
                  _buildTextField(
                    'Net Profit',
                    _netProfitController,
                    'RM 13 100',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Opening Capital',
                    _openingCapitalController,
                    'RM 420',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Drawings', _drawingsController, 'RM 980'),
                  const SizedBox(height: 24),

                  // Non-current assets
                  _buildSection(
                    'Insert Non-Current Assets',
                    _nonCurrentAssets,
                    [
                      'Office Equipment',
                      'Furniture',
                      'Building',
                      'Land',
                      'Vehicle',
                    ],
                  ),

                  // Current assets
                  _buildSection('Insert Current Assets', _currentAssets, [
                    'Inventory',
                    'Accounts Receivable',
                    'Bank',
                    'Cash',
                    'Prepaid Expenses',
                  ]),

                  // Current liabilities
                  _buildSection(
                    'Insert Current Liabilities (-)',
                    _currentLiabilities,
                    [
                      'Accounts Payable',
                      'Notes Payable',
                      'Accrued Expenses',
                      'Short Term Loan',
                    ],
                  ),

                  // Non-current liabilities
                  _buildSection(
                    'Insert Non-Current Liabilities',
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

  Widget _buildSection(
    String title,
    List<Map<String, TextEditingController>> items,
    List<String> options,
  ) {
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
              onPressed: () {
                setState(() {
                  items.add({
                    'type': TextEditingController(),
                    'amount': TextEditingController(),
                  });
                });
              },
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
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value:
                          item['type']!.text.isNotEmpty &&
                              options.contains(item['type']!.text)
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
                      items: options.map((String value) {
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
                        setState(() {
                          item['type']!.text = newValue ?? '';
                        });
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
                  if (items.length > 1)
                    SizedBox(
                      width: 32,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            item['type']?.dispose();
                            item['amount']?.dispose();
                            items.removeAt(index);
                          });
                        },
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
                      : '31/12/2021',
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
