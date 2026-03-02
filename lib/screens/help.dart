import 'package:flutter/material.dart';
import '../widgets/header.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? expandedIndex;

  final List<HelpItem> helpItems = [
    HelpItem(
      question: 'How do I create a Trading Account?',
      answer:
          'Navigate to the Trading Account section from the main menu. Fill in your sales, purchases, opening and closing inventory details. The app will automatically calculate your gross profit or loss.',
      icon: Icons.trending_up,
    ),
    HelpItem(
      question: 'How does document scanning work?',
      answer:
          'Tap the camera icon in any calculation screen. Point your camera at financial documents and the app will automatically extract relevant numbers using OCR technology. Review and confirm the detected values before using them.',
      icon: Icons.document_scanner,
    ),
    HelpItem(
      question: 'How do I save my calculations?',
      answer:
          'All calculations are automatically saved to your history. You can access them from the History section in the main menu. You can also export reports as PDF files.',
      icon: Icons.save,
    ),
    HelpItem(
      question: 'What is Statement of Financial Position?',
      answer:
          'Also known as Balance Sheet, it shows your business\'s financial position at a specific point in time. It lists all assets, liabilities, and equity. The app ensures that Assets = Liabilities + Equity.',
      icon: Icons.assessment,
    ),
    HelpItem(
      question: 'How do I edit my profile?',
      answer:
          'From the dashboard, tap on your company name or use the edit icon next to your profile information. You can update your personal details and company information.',
      icon: Icons.person,
    ),
    HelpItem(
      question: 'Can I use the app offline?',
      answer:
          'Yes, most features work offline. However, document scanning and some advanced features require an internet connection for processing.',
      icon: Icons.wifi_off,
    ),
    HelpItem(
      question: 'How do I reset my password?',
      answer:
          'On the login screen, tap "Forgot Password" and enter your email address. You\'ll receive instructions to reset your password.',
      icon: Icons.lock_reset,
    ),
    HelpItem(
      question: 'Is my financial data secure?',
      answer:
          'Yes, all your data is encrypted and stored securely on your device. We do not store sensitive financial information on external servers.',
      icon: Icons.security,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Help & Support'),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Help Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2C1810), Color(0xFF8B5A84)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5A84).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Need Help?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find answers to common questions below or contact our support team.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.email_outlined,
                    label: 'Email Support',
                    gradient: [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                    ],
                    onTap: () {
                      _showContactDialog(
                        context,
                        'Email Support',
                        'Send us an email at:\nsupport@accountingcalc.com\n\nWe typically respond within 24 hours.',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.phone_outlined,
                    label: 'Call Us',
                    gradient: [
                      const Color(0xFF0F3460),
                      const Color(0xFF16537E),
                    ],
                    onTap: () {
                      _showContactDialog(
                        context,
                        'Phone Support',
                        'Call our support team:\n+1 (555) 123-4567\n\nMonday - Friday: 9 AM - 6 PM EST',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // FAQ Items
            ...helpItems.asMap().entries.map((entry) {
              int index = entry.key;
              HelpItem item = entry.value;
              bool isExpanded = expandedIndex == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ExpansionTile(
                    onExpansionChanged: (expanded) {
                      setState(() {
                        expandedIndex = expanded ? index : null;
                      });
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5A84).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: const Color(0xFF8B5A84),
                      ),
                    ),
                    title: Text(
                      item.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Text(
                          item.answer,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Additional Support Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF533A7B), Color(0xFF7209B7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7209B7).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Still Need Help?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Our support team is here to help you with any questions or issues.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _showContactDialog(
                        context,
                        'Contact Support',
                        'Choose your preferred contact method:\n\n📧 Email: support@accountingcalc.com\n📞 Phone: +1 (555) 123-4567\n🌐 Website: www.accountingcalculator.com',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7209B7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient[1].withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, size: 28, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class HelpItem {
  final String question;
  final String answer;
  final IconData icon;

  HelpItem({required this.question, required this.answer, required this.icon});
}
