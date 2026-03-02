import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/header.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'History',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                Consumer<HistoryProvider>(
                  builder: (context, historyProvider, child) {
                    if (historyProvider.historyItems.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear History'),
                            content: const Text(
                              'Are you sure you want to clear all calculation history?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  historyProvider.clearHistory();
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<HistoryProvider>(
                builder: (context, historyProvider, child) {
                  if (historyProvider.historyItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No calculation history yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your saved calculations will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: historyProvider.historyItems.length,
                    itemBuilder: (context, index) {
                      final historyItem = historyProvider.historyItems[index];
                      return _buildHistoryItem(
                        context,
                        historyItem,
                        historyProvider,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    historyItem,
    HistoryProvider historyProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5A84).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getAccountIcon(historyItem.accountType),
            color: const Color(0xFF8B5A84),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                historyItem.companyName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5A84).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                historyItem.accountType,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B5A84),
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Calculation Date: ${DateFormat('dd/MM/yyyy').format(historyItem.date)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              'Saved: ${DateFormat('dd/MM/yyyy HH:mm').format(historyItem.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                // Navigate to view the calculation details
                _viewCalculationDetails(context, historyItem);
              },
              icon: const Icon(Icons.visibility),
              color: const Color(0xFF8B5A84),
              tooltip: 'View Details',
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete History'),
                    content: const Text(
                      'Are you sure you want to delete this calculation history?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          historyProvider.deleteHistoryItem(historyItem.id);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete),
              color: Colors.red,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccountIcon(String accountType) {
    switch (accountType) {
      case 'Trading Account':
        return Icons.trending_up;
      case 'Profit & Loss Account':
        return Icons.account_balance;
      case 'Statement of Financial Position':
        return Icons.assessment;
      case 'Business Accounting':
        return Icons.business;
      default:
        return Icons.calculate;
    }
  }

  void _viewCalculationDetails(BuildContext context, historyItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(historyItem.accountType),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Company: ${historyItem.companyName}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateFormat('dd/MM/yyyy').format(historyItem.date)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text(
                'Calculation Data:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatCalculationData(historyItem.calculationData),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatCalculationData(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    data.forEach((key, value) {
      if (value is List) {
        buffer.writeln('$key:');
        for (var item in value) {
          buffer.writeln('  - $item');
        }
      } else {
        buffer.writeln('$key: $value');
      }
    });
    return buffer.toString();
  }
}
