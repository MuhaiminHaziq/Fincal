import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/header.dart';
import '../providers/history_provider.dart';
import '../models/history.dart';

class FinancialPositionResultScreen extends StatelessWidget {
  const FinancialPositionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    // Extract data
    final companyName = data['companyName'] as String;
    final date = data['date'] as DateTime;
    final netProfit = double.tryParse(data['netProfit']) ?? 0;
    final openingCapital = double.tryParse(data['openingCapital']) ?? 0;
    final drawings = double.tryParse(data['drawings']) ?? 0;

    final nonCurrentAssets =
        data['nonCurrentAssets'] as List<Map<String, String>>;
    final currentAssets = data['currentAssets'] as List<Map<String, String>>;
    final currentLiabilities =
        data['currentLiabilities'] as List<Map<String, String>>;
    final nonCurrentLiabilities =
        data['nonCurrentLiabilities'] as List<Map<String, String>>;

    // Calculate totals
    final totalNonCurrentAssets = _calculateTotal(nonCurrentAssets);
    final totalCurrentAssets = _calculateTotal(currentAssets);
    final totalCurrentLiabilities = _calculateTotal(currentLiabilities);
    final totalNonCurrentLiabilities = _calculateTotal(nonCurrentLiabilities);

    // Calculate owner's equity
    final netCapital = openingCapital + netProfit;
    final closingCapital = netCapital - drawings;
    final totalOwnerEquity = closingCapital;

    // Calculate total assets and total liabilities + equity
    final totalAssets = totalNonCurrentAssets + totalCurrentAssets;
    final totalLiabilitiesAndEquity =
        totalCurrentLiabilities + totalOwnerEquity + totalNonCurrentLiabilities;

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

              // Company name and title
              Center(
                child: Text(
                  'Statement of Financial Position',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'as at ${DateFormat('dd MMMM yyyy').format(date)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Column Headers - 3 RM columns
              Row(
                children: [
                  const Expanded(flex: 4, child: SizedBox()),
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

              // Asset Semasa (Current Assets)
              const Text(
                'Aset Semasa',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...currentAssets.map(
                (asset) => _buildFinancialRow(
                  asset['type']!,
                  '',
                  _formatCurrency(double.tryParse(asset['amount']!) ?? 0),
                  '',
                ),
              ),
              _buildFinancialRow(
                '',
                '',
                '',
                _formatCurrency(totalCurrentAssets),
              ),
              const SizedBox(height: 16),

              // Tolak: Liabiliti Semasa (Less: Current Liabilities)
              const Text(
                'Tolak: Liabiliti Semasa',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...currentLiabilities.map(
                (liability) => _buildFinancialRow(
                  liability['type']!,
                  '',
                  '(${_formatCurrency(double.tryParse(liability['amount']!) ?? 0)})',
                  '',
                ),
              ),
              _buildFinancialRow(
                '',
                '',
                '',
                '(${_formatCurrency(totalCurrentLiabilities)})',
              ),
              const SizedBox(height: 8),

              // Modal Kerja (Working Capital)
              _buildFinancialRow(
                'Modal Kerja',
                '',
                '',
                _formatCurrency(totalCurrentAssets - totalCurrentLiabilities),
              ),
              const SizedBox(height: 16),

              // Aset Semasa (Non-Current Assets)
              const Text(
                'Aset Bukan Semasa',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...nonCurrentAssets.map(
                (asset) => _buildFinancialRow(
                  asset['type']!,
                  '',
                  _formatCurrency(double.tryParse(asset['amount']!) ?? 0),
                  '',
                ),
              ),
              _buildFinancialRow(
                '',
                '',
                '',
                _formatCurrency(totalNonCurrentAssets),
              ),
              const SizedBox(height: 16),

              // Jumlah Aset Bersih (Total Net Assets)
              _buildFinancialRow(
                'Jumlah Aset Bersih',
                '',
                '',
                _formatCurrency(
                  totalCurrentAssets -
                      totalCurrentLiabilities +
                      totalNonCurrentAssets,
                ),
              ),
              const SizedBox(height: 16),

              // Pemilikan (Owner's Equity)
              const Text(
                'Pemilikan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildFinancialRow(
                'Modal Awal',
                '',
                _formatCurrency(openingCapital),
                '',
              ),
              _buildFinancialRow(
                'Tambah: Untung Bersih',
                '',
                _formatCurrency(netProfit),
                '',
              ),
              const Divider(),
              _buildFinancialRow(
                '',
                '',
                '',
                _formatCurrency(openingCapital + netProfit),
              ),
              _buildFinancialRow(
                'Tolak: Cabutan',
                '',
                '(${_formatCurrency(drawings)})',
                '',
              ),
              const Divider(),
              _buildFinancialRow(
                'Modal Akhir',
                '',
                '',
                _formatCurrency(closingCapital),
              ),
              const SizedBox(height: 16),

              // Liabiliti Bukan Semasa (Non-Current Liabilities)
              if (nonCurrentLiabilities.isNotEmpty) ...[
                const Text(
                  'Liabiliti Bukan Semasa',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ...nonCurrentLiabilities.map(
                  (liability) => _buildFinancialRow(
                    liability['type']!,
                    '',
                    _formatCurrency(double.tryParse(liability['amount']!) ?? 0),
                    '',
                  ),
                ),
                _buildFinancialRow(
                  '',
                  '',
                  '',
                  _formatCurrency(totalNonCurrentLiabilities),
                ),
                const SizedBox(height: 16),
              ],

              // Final Total with double line
              const Divider(thickness: 2),
              _buildFinancialRow(
                '',
                '',
                '',
                _formatCurrency(closingCapital + totalNonCurrentLiabilities),
                isBold: true,
              ),
              const Divider(thickness: 2),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _saveToHistory(
                        context,
                        data,
                        totalLiabilitiesAndEquity,
                      ),
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

  Widget _buildFinancialRow(
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
            flex: 4,
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

  double _calculateTotal(List<Map<String, String>> items) {
    return items.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['amount'] ?? '0') ?? 0);
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount);
  }

  void _saveToHistory(
    BuildContext context,
    Map<String, dynamic> data,
    double total,
  ) {
    final historyProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );

    final historyItem = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: data['companyName'],
      accountType: 'Statement of Financial Position',
      date: data['date'] as DateTime,
      calculationData: data,
      createdAt: DateTime.now(),
    );

    historyProvider.addItem(historyItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Financial position saved to history'),
        backgroundColor: Color(0xFF8B5A84),
      ),
    );
  }

  void _printPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF generation feature coming soon'),
        backgroundColor: Color(0xFF8B5A84),
      ),
    );
  }
}
