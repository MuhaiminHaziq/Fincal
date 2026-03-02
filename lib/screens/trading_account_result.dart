import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/header.dart';
import '../providers/history_provider.dart';
import '../models/history.dart';

class TradingAccountResultScreen extends StatelessWidget {
  const TradingAccountResultScreen({super.key});

  double _parseAmount(String? amount) {
    if (amount == null || amount.isEmpty) return 0.0;
    return double.tryParse(amount.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0.0;
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,##0').format(amount);
  }

  Future<void> _saveReport(
    BuildContext context,
    Map<String, dynamic> data,
    Map<String, dynamic> calculations,
  ) async {
    try {
      final historyProvider = Provider.of<HistoryProvider>(
        context,
        listen: false,
      );

      final historyItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyName: data['companyName'] ?? 'Unknown Company',
        accountType: 'Trading Account',
        date: data['date'] ?? DateTime.now(),
        calculationData: {'inputData': data, 'calculations': calculations},
        createdAt: DateTime.now(),
      );

      historyProvider.addItem(historyItem);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trading account saved to history'),
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

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (data == null) {
      return Scaffold(
        appBar: const Header(),
        body: const Center(child: Text('No data available')),
      );
    }

    // Extract and parse data
    final sales = _parseAmount(data['sales']);
    final salesReturn = _parseAmount(data['salesReturn']);
    final openingInventory = _parseAmount(data['openingInventory']);
    final purchases = _parseAmount(data['purchases']);
    final purchasesReturn = _parseAmount(data['purchasesReturn']);
    final closingInventory = _parseAmount(data['closingInventory']);

    final costOfSalesList = data['costOfSales'] as List<dynamic>? ?? [];

    // Calculate total cost of sales from ALL items
    final totalCostOfSalesAmount = costOfSalesList.fold<double>(0.0, (
      sum,
      item,
    ) {
      return sum + _parseAmount(item['amount']?.toString());
    });

    // Perform calculations
    final netSales = sales - salesReturn;
    final netPurchases = purchases - purchasesReturn;
    final totalPurchasesCost = netPurchases + totalCostOfSalesAmount;
    final costAvailableForSale = openingInventory + totalPurchasesCost;
    final costOfSalesAmount = costAvailableForSale - closingInventory;
    final grossProfit = netSales - costOfSalesAmount;

    final calculations = {
      'sales': sales,
      'salesReturn': salesReturn,
      'netSales': netSales,
      'openingInventory': openingInventory,
      'purchases': purchases,
      'purchasesReturn': purchasesReturn,
      'netPurchases': netPurchases,
      'totalCostOfSalesAmount': totalCostOfSalesAmount,
      'totalPurchasesCost': totalPurchasesCost,
      'costAvailableForSale': costAvailableForSale,
      'closingInventory': closingInventory,
      'costOfSalesAmount': costOfSalesAmount,
      'grossProfit': grossProfit,
    };

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
              const Center(
                child: Text(
                  'Accounting Calculator',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(child: Divider(thickness: 2)),
              const SizedBox(height: 16),

              // Company and title
              Center(
                child: Text(
                  'Trading Account',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'for the year ended ${data['date'] != null ? DateFormat('dd MMMM yyyy').format(data['date']) : '30 January 2024'}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Column Headers
              Row(
                children: [
                  const Expanded(flex: 3, child: SizedBox()),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'RM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'RM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'RM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Sales Section
              _buildAccountingRow('Sales', '', '', _formatAmount(sales)),
              _buildAccountingRow(
                '(-): Sales Return',
                '',
                '',
                '-${_formatAmount(salesReturn)}',
              ),
              const Divider(),
              _buildAccountingRow('Net Sales', '', '', _formatAmount(netSales)),
              const SizedBox(height: 16),

              // Purchases and Cost Section
              _buildAccountingRow(
                'Opening Inventory',
                '',
                _formatAmount(openingInventory),
                '',
              ),
              _buildAccountingRow(
                'Purchases',
                _formatAmount(purchases),
                '',
                '',
              ),
              _buildAccountingRow(
                '(-): Purchases Return',
                '-${_formatAmount(purchasesReturn)}',
                '',
                '',
              ),
              const Divider(),
              _buildAccountingRow(
                'Net Purchases',
                _formatAmount(netPurchases),
                '',
                '',
              ),
              // Display all cost of sales items
              ...costOfSalesList
                  .where(
                    (item) =>
                        item['type']?.toString().isNotEmpty == true &&
                        item['amount']?.toString().isNotEmpty == true,
                  )
                  .map(
                    (item) => _buildAccountingRow(
                      item['type']?.toString() ?? '',
                      _formatAmount(_parseAmount(item['amount']?.toString())),
                      '',
                      '',
                    ),
                  ),
              const Divider(),
              _buildAccountingRow(
                'Total Purchases Cost',
                '',
                _formatAmount(totalPurchasesCost),
                '',
              ),
              const Divider(),
              _buildAccountingRow(
                'Cost Available for Sale',
                '',
                _formatAmount(costAvailableForSale),
                '',
              ),
              _buildAccountingRow(
                '(-): Closing Inventory',
                '',
                '-${_formatAmount(closingInventory)}',
                '',
              ),
              const Divider(),
              _buildAccountingRow(
                'Cost of Sales',
                '',
                '',
                '-${_formatAmount(costOfSalesAmount)}',
              ),
              const SizedBox(height: 16),

              // Gross Profit with double line
              const Divider(thickness: 2),
              _buildAccountingRow(
                'Gross Profit',
                '',
                '',
                _formatAmount(grossProfit),
                isBold: true,
              ),
              const Divider(thickness: 2),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _saveReport(context, data, calculations),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8B5A84)),
                        foregroundColor: const Color(0xFF8B5A84),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/dashboard',
                        (route) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5A84),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Menu'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            flex: 2,
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
            flex: 2,
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
            flex: 2,
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
}
