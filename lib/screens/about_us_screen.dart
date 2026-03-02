import 'package:flutter/material.dart';
import '../widgets/header.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'About Us'),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Title Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.calculate,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Accounting Calculator',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // About Section
            _buildInfoCard(
              title: 'About Our App',
              icon: Icons.info_outline,
              gradient: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
              content:
                  'Accounting Calculator is a comprehensive mobile application designed to simplify financial calculations for businesses. Our app provides easy-to-use interfaces for Trading Accounts, Profit & Loss statements, and Statement of Financial Position calculations.',
            ),

            const SizedBox(height: 16),

            // Features Section
            _buildInfoCard(
              title: 'Key Features',
              icon: Icons.star_outline,
              gradient: [const Color(0xFF0F3460), const Color(0xFF16537E)],
              content:
                  '• Document scanning with OCR technology\n• Automated financial calculations\n• History tracking and report generation\n• User-friendly interface design\n• Secure data storage',
            ),

            const SizedBox(height: 16),

            // Mission Section
            _buildInfoCard(
              title: 'Our Mission',
              icon: Icons.rocket_launch_outlined,
              gradient: [const Color(0xFF533A7B), const Color(0xFF7209B7)],
              content:
                  'To empower businesses and individuals with accessible, accurate, and efficient accounting tools that simplify financial management and decision-making processes.',
            ),

            const SizedBox(height: 16),

            // Contact Section
            _buildInfoCard(
              title: 'Contact Information',
              icon: Icons.contact_mail_outlined,
              gradient: [const Color(0xFF2D4A22), const Color(0xFF90C695)],
              content:
                  'For support or inquiries:\n\nEmail: support@accountingcalc.com\nPhone: +1 (555) 123-4567\nWebsite: www.accountingcalculator.com',
            ),

            const SizedBox(height: 24),

            // Copyright Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: const Text(
                '© 2024 Accounting Calculator. All rights reserved.\nBuilt with Flutter framework.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[1].withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
