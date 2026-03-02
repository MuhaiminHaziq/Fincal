import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/header.dart';
import '../providers/history_provider.dart';
import '../models/history.dart';

class ProfitLossResultScreen extends StatelessWidget {
  const ProfitLossResultScreen({super.key});

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
    Map<String, double> calculations,
  ) async {
    try {
      final historyProvider = Provider.of<HistoryProvider>(
        context,
        listen: false,
      );

      final historyItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyName: data['companyName'] ?? 'Unknown Company',
        accountType: 'Profit & Loss Account',
        date: data['date'] ?? DateTime.now(),
        calculationData: {'inputData': data, 'calculations': calculations},
        createdAt: DateTime.now(),
      );

      historyProvider.addItem(historyItem);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profit & Loss account saved to history'),
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

    final grossProfit = _parseAmount(data['grossProfit']);
    final revenues = data['revenues'] as List<dynamic>? ?? [];
    final expenses = data['expenses'] as List<dynamic>? ?? [];

    final totalRevenues = revenues.fold<double>(0.0, (sum, item) {
      return sum + _parseAmount(item['amount']);
    });

    final totalExpenses = expenses.fold<double>(0.0, (sum, item) {
      return sum + _parseAmount(item['amount']);
    });

    final netProfit = (grossProfit + totalRevenues) - totalExpenses;

    final calculations = {
      'grossProfit': grossProfit,
      'totalRevenues': totalRevenues,
      'totalExpenses': totalExpenses,
      'netProfit': netProfit,
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
                  'Profit & Loss Account',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'as on ${data['date'] != null ? DateFormat('dd MMMM yyyy').format(data['date']) : '31 December 2025'}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Column Headers - 2 columns of RM
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
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Gross Profit
              _buildAccountingRow(
                'Gross Profit',
                '',
                _formatAmount(grossProfit),
              ),
              const SizedBox(height: 16),

              // Revenues - items in middle RM column, total on right RM column
              if (revenues.isNotEmpty) ...[
                const Text(
                  '(+) : Revenue',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ...revenues.map(
                  (revenue) => _buildAccountingRow(
                    revenue['type'],
                    _formatAmount(_parseAmount(revenue['amount'])),
                    '',
                  ),
                ),
                const Divider(),
                _buildAccountingRow(
                  '',
                  '',
                  _formatAmount(grossProfit + totalRevenues),
                  isBold: true,
                ),
                const SizedBox(height: 16),
              ],

              // Expenses - items in middle RM column, total on right RM column
              if (expenses.isNotEmpty) ...[
                const Text(
                  '(-) : Expenses',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ...expenses.map(
                  (expense) => _buildAccountingRow(
                    expense['type'],
                    _formatAmount(_parseAmount(expense['amount'])),
                    '',
                  ),
                ),
                const Divider(),
                _buildAccountingRow(
                  '',
                  '',
                  '-${_formatAmount(totalExpenses)}',
                  isBold: true,
                ),
                const SizedBox(height: 16),
              ],

              // Net Profit with double line
              const Divider(thickness: 2),
              _buildAccountingRow(
                'Net Profit',
                '',
                _formatAmount(netProfit),
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
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
