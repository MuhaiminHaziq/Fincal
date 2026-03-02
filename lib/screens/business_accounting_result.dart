import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/header.dart';
import '../providers/history_provider.dart';
import '../models/history.dart';
import '../providers/auth_provider.dart';

class BusinessAccountingResultScreen extends StatefulWidget {
  const BusinessAccountingResultScreen({super.key});

  @override
  State<BusinessAccountingResultScreen> createState() =>
      _BusinessAccountingResultScreenState();
}

class _BusinessAccountingResultScreenState
    extends State<BusinessAccountingResultScreen> {
  bool _showIncomeStatement = true;
  Map<String, dynamic>? _data;
  Map<String, double> _calculations = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (_data != null) {
      _performCalculations();
    }
  }

  void _performCalculations() {
    if (_data == null) return;

    // Parse basic trading account amounts
    final sales = _parseAmount(_data?['sales']);
    final salesReturn = _parseAmount(_data?['salesReturn']);
    final openingInventory = _parseAmount(_data?['openingInventory']);
    final purchases = _parseAmount(_data?['purchases']);
    final purchasesReturn = _parseAmount(_data?['purchasesReturn']);
    final closingInventory = _parseAmount(_data?['closingInventory']);

    // Cost of sales items
    final costOfSalesList = _data?['costOfSales'] as List<dynamic>? ?? [];
    double carriageInwards = 0;
    double tax = 0;

    for (var item in costOfSalesList) {
      if (item is Map<String, dynamic>) {
        final type = item['type']?.toString().toLowerCase() ?? '';
        final amount = _parseAmount(item['amount']?.toString());

        if (type.contains('carriage')) {
          carriageInwards += amount;
        } else if (type.contains('tax') || type.contains('service')) {
          tax += amount;
        }
      }
    }

    // Trading Account calculations
    final netSales = sales - salesReturn;
    final netPurchases = purchases - purchasesReturn;
    final totalPurchaseCost = netPurchases + carriageInwards + tax;
    final costAvailableForSale = openingInventory + totalPurchaseCost;
    final costOfSales = costAvailableForSale - closingInventory;
    final grossProfit = netSales - costOfSales;

    // P&L calculations
    final revenues = _data?['revenues'] as List<dynamic>? ?? [];
    final expenses = _data?['expenses'] as List<dynamic>? ?? [];

    final totalRevenues = revenues.fold<double>(0.0, (sum, item) {
      if (item is Map<String, dynamic>) {
        return sum + _parseAmount(item['amount']?.toString());
      }
      return sum;
    });

    final totalExpenses = expenses.fold<double>(0.0, (sum, item) {
      if (item is Map<String, dynamic>) {
        return sum + _parseAmount(item['amount']?.toString());
      }
      return sum;
    });

    final netProfit = grossProfit + totalRevenues - totalExpenses;

    // Financial Position calculations
    final openingCapital = _parseAmount(_data?['openingCapital']);
    final drawings = _parseAmount(_data?['drawings']);

    final nonCurrentAssets = _data?['nonCurrentAssets'] as List<dynamic>? ?? [];
    final currentAssets = _data?['currentAssets'] as List<dynamic>? ?? [];
    final currentLiabilities =
        _data?['currentLiabilities'] as List<dynamic>? ?? [];
    final nonCurrentLiabilities =
        _data?['nonCurrentLiabilities'] as List<dynamic>? ?? [];

    final totalNonCurrentAssets = _calculateListTotal(nonCurrentAssets);
    final totalCurrentAssets = _calculateListTotal(currentAssets);
    final totalCurrentLiabilities = _calculateListTotal(currentLiabilities);
    final totalNonCurrentLiabilities = _calculateListTotal(
      nonCurrentLiabilities,
    );

    final workingCapital = totalCurrentAssets - totalCurrentLiabilities;
    final capitalWithProfit = openingCapital + netProfit;
    final closingCapital = capitalWithProfit - drawings;

    _calculations = {
      'sales': sales,
      'salesReturn': salesReturn,
      'netSales': netSales,
      'openingInventory': openingInventory,
      'purchases': purchases,
      'purchasesReturn': purchasesReturn,
      'netPurchases': netPurchases,
      'carriageInwards': carriageInwards,
      'tax': tax,
      'totalPurchaseCost': totalPurchaseCost,
      'costAvailableForSale': costAvailableForSale,
      'closingInventory': closingInventory,
      'costOfSales': costOfSales,
      'grossProfit': grossProfit,
      'totalRevenues': totalRevenues,
      'totalExpenses': totalExpenses,
      'netProfit': netProfit,
      'openingCapital': openingCapital,
      'drawings': drawings,
      'capitalWithProfit': capitalWithProfit,
      'closingCapital': closingCapital,
      'totalNonCurrentAssets': totalNonCurrentAssets,
      'totalCurrentAssets': totalCurrentAssets,
      'totalCurrentLiabilities': totalCurrentLiabilities,
      'totalNonCurrentLiabilities': totalNonCurrentLiabilities,
      'workingCapital': workingCapital,
    };
  }

  double _parseAmount(String? amount) {
    if (amount == null || amount.isEmpty) return 0.0;
    return double.tryParse(amount.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0.0;
  }

  double _calculateListTotal(List<dynamic> items) {
    return items.fold<double>(0.0, (sum, item) {
      if (item is Map<String, dynamic>) {
        return sum + _parseAmount(item['amount']?.toString());
      }
      return sum;
    });
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,##0').format(amount);
  }

  Future<void> _saveReport(BuildContext context) async {
    try {
      final historyProvider = Provider.of<HistoryProvider>(
        context,
        listen: false,
      );

      final historyItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyName: _data?['companyName'] ?? 'Unknown Company',
        accountType: 'Business Accounting',
        date: _data?['date'] ?? DateTime.now(),
        calculationData: {
          'inputData': _data ?? {},
          'calculations': _calculations,
        },
        createdAt: DateTime.now(),
      );

      historyProvider.addItem(historyItem);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business accounting saved to history'),
            backgroundColor: Color(0xFF8B5A84),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save report')));
      }
    }
  }

  void _printPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF generation feature coming soon'),
        backgroundColor: Color(0xFF8B5A84),
      ),
    );
  }

  Widget _buildIncomeStatementButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _saveReport(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF8B5A84)),
              foregroundColor: const Color(0xFF8B5A84),
            ),
            child: const Text('Save'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _showIncomeStatement = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5A84),
              foregroundColor: Colors.white,
            ),
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialPositionButtons() {
    return Column(
      children: [
        // Balance message
        _buildBalanceMessage(),
        const SizedBox(height: 16),

        // Button rows
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _showIncomeStatement = true),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF8B5A84)),
                  foregroundColor: const Color(0xFF8B5A84),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _printPDF(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF8B5A84)),
                  foregroundColor: const Color(0xFF8B5A84),
                ),
                child: const Text('Print PDF'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/dashboard',
                  (route) => false,
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF8B5A84)),
                  foregroundColor: const Color(0xFF8B5A84),
                ),
                child: const Text('Menu'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _saveReport(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF8B5A84)),
              foregroundColor: const Color(0xFF8B5A84),
            ),
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceMessage() {
    final totalNetAssets =
        (_calculations['totalNonCurrentAssets'] ?? 0) +
        (_calculations['workingCapital'] ?? 0);
    final totalEquityAndLiabilities =
        (_calculations['closingCapital'] ?? 0) +
        (_calculations['totalNonCurrentLiabilities'] ?? 0);
    final isBalanced =
        (totalNetAssets - totalEquityAndLiabilities).abs() <
        0.01; // Handle floating point precision

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isBalanced ? Colors.green : Colors.red,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isBalanced
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.error,
            color: isBalanced ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isBalanced
                  ? 'Statement is balanced: Total Net Assets (${_formatAmount(totalNetAssets)}) equals Equity and Non-Current Liabilities (${_formatAmount(totalEquityAndLiabilities)})'
                  : 'Statement is not balanced: Total Net Assets (${_formatAmount(totalNetAssets)}) does not equal Equity and Non-Current Liabilities (${_formatAmount(totalEquityAndLiabilities)})',
              style: TextStyle(
                fontSize: 12,
                color: isBalanced ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return Scaffold(
        appBar: const Header(),
        body: const Center(child: Text('No data available')),
      );
    }

    return Scaffold(
      appBar: const Header(),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(20),
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
              // Header
              Center(
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      authProvider.user?.companyName ?? 'Accounting Calculator',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              const Center(child: Divider(thickness: 2)),
              const SizedBox(height: 16),

              // Toggle buttons
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showIncomeStatement = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _showIncomeStatement
                                ? const Color(0xFF8B5A84)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Income Statement',
                            style: TextStyle(
                              color: _showIncomeStatement
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showIncomeStatement = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: !_showIncomeStatement
                                ? const Color(0xFF8B5A84)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Financial Position',
                            style: TextStyle(
                              color: !_showIncomeStatement
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Content
              _showIncomeStatement
                  ? _buildIncomeStatement()
                  : _buildFinancialPosition(),

              const SizedBox(height: 32),

              // Action buttons
              _showIncomeStatement
                  ? _buildIncomeStatementButtons()
                  : _buildFinancialPositionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeStatement() {
    final revenues = _data?['revenues'] as List<dynamic>? ?? [];
    final expenses = _data?['expenses'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Center(
          child: Text(
            'Income Statement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const Center(
          child: Text(
            'for the year ended 30 January 2024',
            style: TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),

        // Column Headers
        Row(
          children: const [
            Expanded(flex: 3, child: SizedBox()),
            Expanded(
              flex: 1,
              child: Text(
                'RM',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'RM',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'RM',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Trading Account Section
        _buildAccountingRow(
          'Sales',
          '',
          '',
          _formatAmount(_calculations['sales'] ?? 0),
        ),
        _buildAccountingRow(
          '(-): Sales Return',
          '',
          '',
          '-${_formatAmount(_calculations['salesReturn'] ?? 0)}',
        ),
        const Divider(),
        _buildAccountingRow(
          'Net Sales',
          '',
          '',
          _formatAmount(_calculations['netSales'] ?? 0),
        ),
        const SizedBox(height: 8),

        _buildAccountingRow(
          'Opening Inventory',
          '',
          _formatAmount(_calculations['openingInventory'] ?? 0),
          '',
        ),
        _buildAccountingRow(
          'Purchases',
          _formatAmount(_calculations['purchases'] ?? 0),
          '',
          '',
        ),
        _buildAccountingRow(
          '(-): Purchases Return',
          '-${_formatAmount(_calculations['purchasesReturn'] ?? 0)}',
          '',
          '',
        ),
        const Divider(),
        _buildAccountingRow(
          'Net Purchases',
          _formatAmount(_calculations['netPurchases'] ?? 0),
          '',
          '',
        ),
        _buildAccountingRow(
          'Carriage Inwards',
          _formatAmount(_calculations['carriageInwards'] ?? 0),
          '',
          '',
        ),
        _buildAccountingRow(
          'Tax',
          _formatAmount(_calculations['tax'] ?? 0),
          '',
          '',
        ),
        const Divider(),
        _buildAccountingRow(
          'Total Purchase Cost',
          '',
          _formatAmount(_calculations['totalPurchaseCost'] ?? 0),
          '',
        ),
        const Divider(),
        _buildAccountingRow(
          'Cost Available for Sale',
          '',
          _formatAmount(_calculations['costAvailableForSale'] ?? 0),
          '',
        ),
        _buildAccountingRow(
          '(-): Closing Inventory',
          '',
          '-${_formatAmount(_calculations['closingInventory'] ?? 0)}',
          '',
        ),
        const Divider(),
        _buildAccountingRow(
          'Cost of Sales',
          '',
          '',
          '-${_formatAmount(_calculations['costOfSales'] ?? 0)}',
        ),
        const Divider(thickness: 2),
        _buildAccountingRow(
          'Gross Profit',
          '',
          '',
          _formatAmount(_calculations['grossProfit'] ?? 0),
          isBold: true,
        ),
        const SizedBox(height: 16),

        // Revenue Section
        _buildAccountingRow(
          '(+): revenue',
          '',
          '',
          _formatAmount(_calculations['totalRevenues'] ?? 0),
        ),
        ...revenues
            .where(
              (item) =>
                  item is Map<String, dynamic> &&
                  _parseAmount(item['amount']?.toString()) > 0,
            )
            .map(
              (item) => _buildAccountingRow(
                item['type']?.toString() ?? '',
                '',
                _formatAmount(_parseAmount(item['amount']?.toString())),
                '',
              ),
            ),
        const SizedBox(height: 8),

        // Expense Section
        _buildAccountingRow(
          '(+): expenses',
          '',
          '',
          _formatAmount(_calculations['totalExpenses'] ?? 0),
        ),
        ...expenses
            .where(
              (item) =>
                  item is Map<String, dynamic> &&
                  _parseAmount(item['amount']?.toString()) > 0,
            )
            .map(
              (item) => _buildAccountingRow(
                item['type']?.toString() ?? '',
                '',
                _formatAmount(_parseAmount(item['amount']?.toString())),
                '',
              ),
            ),
        const Divider(),
        _buildAccountingRow(
          '',
          '',
          '',
          '-${_formatAmount(_calculations['totalExpenses'] ?? 0)}',
        ),
        const Divider(thickness: 2),

        // Net Profit
        _buildAccountingRow(
          'Net Profit',
          '',
          '',
          _formatAmount(_calculations['netProfit'] ?? 0),
          isBold: true,
        ),
        const Divider(thickness: 2),
      ],
    );
  }

  Widget _buildFinancialPosition() {
    final nonCurrentAssets = _data?['nonCurrentAssets'] as List<dynamic>? ?? [];
    final currentAssets = _data?['currentAssets'] as List<dynamic>? ?? [];
    final currentLiabilities =
        _data?['currentLiabilities'] as List<dynamic>? ?? [];
    final nonCurrentLiabilities =
        _data?['nonCurrentLiabilities'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Center(
          child: Text(
            'Statement of Financial Position',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const Center(
          child: Text('as at 31 December 2021', style: TextStyle(fontSize: 14)),
        ),
        const SizedBox(height: 24),

        // Column Headers
        Row(
          children: const [
            Expanded(flex: 3, child: SizedBox()),
            Expanded(
              flex: 1,
              child: Text(
                'RM',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'RM',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Non-Current Assets
        _buildFinancialRow('Non-Current Asset', '', ''),
        ...nonCurrentAssets
            .where(
              (item) =>
                  item is Map<String, dynamic> &&
                  _parseAmount(item['amount']?.toString()) > 0,
            )
            .map(
              (item) => _buildFinancialRow(
                item['type']?.toString() ?? '',
                _formatAmount(_parseAmount(item['amount']?.toString())),
                '',
              ),
            ),
        const Divider(),
        _buildFinancialRow(
          '',
          '',
          _formatAmount(_calculations['totalNonCurrentAssets'] ?? 0),
        ),
        const SizedBox(height: 8),

        // Current Assets
        _buildFinancialRow('Current Assets', '', ''),
        ...currentAssets
            .where(
              (item) =>
                  item is Map<String, dynamic> &&
                  _parseAmount(item['amount']?.toString()) > 0,
            )
            .map(
              (item) => _buildFinancialRow(
                item['type']?.toString() ?? '',
                _formatAmount(_parseAmount(item['amount']?.toString())),
                '',
              ),
            ),
        const Divider(),
        _buildFinancialRow(
          '',
          '',
          _formatAmount(_calculations['totalCurrentAssets'] ?? 0),
        ),
        const SizedBox(height: 8),

        // Current Liabilities
        _buildFinancialRow('(-): Current Liabilities', '', ''),
        ...currentLiabilities
            .where(
              (item) =>
                  item is Map<String, dynamic> &&
                  _parseAmount(item['amount']?.toString()) > 0,
            )
            .map(
              (item) => _buildFinancialRow(
                item['type']?.toString() ?? '',
                '-${_formatAmount(_parseAmount(item['amount']?.toString()))}',
                '',
              ),
            ),
        const Divider(),
        _buildFinancialRow(
          'Working Capital',
          '',
          _formatAmount(_calculations['workingCapital'] ?? 0),
        ),
        const Divider(),
        _buildFinancialRow(
          '',
          '',
          _formatAmount(
            (_calculations['totalNonCurrentAssets'] ?? 0) +
                (_calculations['workingCapital'] ?? 0),
          ),
        ),
        const SizedBox(height: 16),

        // Owner's Equity
        _buildFinancialRow('Owner\'s Equity', '', ''),
        _buildFinancialRow(
          'Opening Capital',
          _formatAmount(_calculations['openingCapital'] ?? 0),
          '',
        ),
        _buildFinancialRow(
          '(+): Net Profit',
          _formatAmount(_calculations['netProfit'] ?? 0),
          '',
        ),
        const Divider(),
        _buildFinancialRow(
          '',
          '',
          _formatAmount(_calculations['capitalWithProfit'] ?? 0),
        ),
        _buildFinancialRow(
          '(-): Drawings',
          '-${_formatAmount(_calculations['drawings'] ?? 0)}',
          '',
        ),
        const Divider(),
        _buildFinancialRow(
          'Closing Capital',
          '',
          _formatAmount(_calculations['closingCapital'] ?? 0),
        ),
        const SizedBox(height: 8),

        // Non-Current Liabilities
        _buildFinancialRow('Non-Current Liabilities', '', ''),
        ...nonCurrentLiabilities
            .where(
              (item) =>
                  item is Map<String, dynamic> &&
                  _parseAmount(item['amount']?.toString()) > 0,
            )
            .map(
              (item) => _buildFinancialRow(
                item['type']?.toString() ?? '',
                _formatAmount(_parseAmount(item['amount']?.toString())),
                '',
              ),
            ),
        const Divider(),
        _buildFinancialRow(
          '',
          '',
          _formatAmount(
            (_calculations['closingCapital'] ?? 0) +
                (_calculations['totalNonCurrentLiabilities'] ?? 0),
          ),
          isBold: true,
        ),
        const Divider(thickness: 2),
      ],
    );
  }

  Widget _buildAccountingRow(
    String label,
    String col1,
    String col2,
    String col3, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col3,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
    String label,
    String col1,
    String col2, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
