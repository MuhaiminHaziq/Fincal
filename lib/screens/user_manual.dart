import 'package:flutter/material.dart';
import '../widgets/header.dart';

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({super.key});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  int selectedSection = 0;
  bool isSidebarVisible = true;

  final List<ManualSection> manualSections = [
    ManualSection(
      title: 'Getting Started',
      icon: Icons.play_circle_outline,
      gradient: [const Color(0xFF2C1810), const Color(0xFF8B5A84)],
      content: '''
Welcome to Accounting Calculator! This guide will help you get started with the app.

1. Creating Your Account
   • Open the app and tap "Sign Up"
   • Enter your personal and company details
   • Verify your email address
   • Set a secure password

2. First Login
   • Enter your credentials on the login screen
   • Access the main dashboard
   • Familiarize yourself with the menu options

3. Setting Up Your Profile
   • Tap on your company name in the dashboard
   • Update your business information
   • Configure your preferences
   • Save your changes

4. Understanding the Interface
   • Dashboard: Main hub with all features
   • Navigation: Use the top menu buttons
   • History: Access all saved calculations
   • Settings: Customize app preferences
''',
    ),
    ManualSection(
      title: 'Trading Account',
      icon: Icons.trending_up,
      gradient: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
      content: '''
Learn how to create and manage Trading Accounts effectively.

1. Accessing Trading Account
   • From dashboard, tap "Trading Account"
   • You'll see the trading account form

2. Required Information
   • Sales: Total sales for the period
   • Sales Returns: Goods returned by customers
   • Opening Inventory: Stock at period start
   • Purchases: Total purchases made
   • Purchase Returns: Goods returned to suppliers
   • Closing Inventory: Stock at period end

3. Additional Costs
   • Add cost of sales items like:
     - Carriage Inwards
     - Import duties
     - Storage costs

4. Using Document Scanner
   • Tap the camera icon
   • Point camera at financial documents
   • Review auto-detected values
   • Confirm and use the data

5. Calculating Results
   • Tap "Calculate" to generate results
   • Review Gross Profit/Loss
   • Save or export the report
''',
    ),
    ManualSection(
      title: 'Profit & Loss Account',
      icon: Icons.account_balance,
      gradient: [const Color(0xFF0F3460), const Color(0xFF16537E)],
      content: '''
Master the Profit & Loss Account creation process.

1. Starting P&L Account
   • Navigate to "Profit & Loss Account"
   • Import gross profit from Trading Account
   • Or enter manually if starting fresh

2. Revenue Items
   • Add all income sources:
     - Commission received
     - Rent received
     - Interest received
     - Discount received

3. Expense Categories
   • Operating Expenses:
     - Salaries and wages
     - Rent and utilities
     - Insurance
     - Depreciation
   • Administrative Expenses:
     - Office supplies
     - Professional fees
     - Bank charges

4. Managing Dynamic Lists
   • Tap "+" to add new items
   • Enter description and amount
   • Use the "×" button to remove items
   • Reorder items by dragging

5. Final Calculations
   • Net Profit = Gross Profit + Revenues - Expenses
   • Review all calculations
   • Generate comprehensive reports
''',
    ),
    ManualSection(
      title: 'Financial Position',
      icon: Icons.assessment,
      gradient: [const Color(0xFF533A7B), const Color(0xFF7209B7)],
      content: '''
Create accurate Statement of Financial Position (Balance Sheet).

1. Understanding Balance Sheet
   • Assets = Liabilities + Equity
   • Shows financial position at a point in time
   • Must balance for accuracy

2. Non-Current Assets
   • Long-term assets:
     - Buildings and land
     - Equipment and machinery
     - Vehicles
     - Investments

3. Current Assets
   • Short-term assets:
     - Cash and bank balances
     - Accounts receivable
     - Inventory
     - Prepaid expenses

4. Liabilities Classification
   • Current Liabilities (due within 1 year):
     - Accounts payable
     - Short-term loans
     - Accrued expenses
   • Non-Current Liabilities (due after 1 year):
     - Long-term loans
     - Mortgages
     - Deferred tax

5. Equity Section
   • Owner's equity components:
     - Capital contributions
     - Retained earnings
     - Current year profit/loss

6. Balancing the Sheet
   • App automatically checks balance
   • Shows any discrepancies
   • Helps identify errors
''',
    ),
    ManualSection(
      title: 'Business Accounting',
      icon: Icons.business,
      gradient: [const Color(0xFF2D4A22), const Color(0xFF90C695)],
      content: '''
Complete business accounting cycle from start to finish.

1. Comprehensive Workflow
   • Combines all accounting statements
   • Flows from Trading Account to P&L to Financial Position
   • Provides complete financial picture

2. Data Entry Process
   • Start with trading account data
   • Proceed to profit & loss items
   • Complete with balance sheet information
   • Use scanning for quick data entry

3. Integrated Calculations
   • Gross profit flows to P&L
   • Net profit flows to equity
   • All calculations are linked
   • Changes update automatically

4. Report Generation
   • Income Statement view
   • Statement of Financial Position view
   • Toggle between reports
   • Export options available

5. Validation Features
   • Balance sheet balancing check
   • Mathematical accuracy verification
   • Error highlighting
   • Correction suggestions

6. Saving and History
   • Auto-save functionality
   • Access from history menu
   • Compare different periods
   • Track business performance
''',
    ),
    ManualSection(
      title: 'Advanced Features',
      icon: Icons.settings,
      gradient: [const Color(0xFF8B4513), const Color(0xFFD2691E)],
      content: '''
Explore advanced features and tips for power users.

1. Document Scanning OCR
   • Supports multiple document types
   • Recognizes financial data patterns
   • Learns from corrections
   • Works with printed and handwritten text

2. History and Analytics
   • Track calculation history
   • Compare different periods
   • Identify trends and patterns
   • Generate performance insights

3. Data Export Options
   • PDF report generation
   • Sharing capabilities
   • Backup and restore
   • Multiple format support

4. Security Features
   • Local data encryption
   • Secure authentication
   • Privacy protection
   • Data isolation

5. Customization Options
   • Company branding
   • Report templates
   • Currency settings
   • Date format preferences

6. Troubleshooting
   • Common error solutions
   • Performance optimization
   • Data recovery options
   • Support contact methods

7. Best Practices
   • Regular data backups
   • Consistent data entry
   • Regular account reconciliation
   • Periodic report reviews
''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'User Manual'),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Row(
          children: [
          // Collapsible Sidebar
          if (isSidebarVisible)
            Container(
              width: 180,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2C1810), Color(0xFF8B5A84)],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sections',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isSidebarVisible = false;
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: manualSections.length,
                      itemBuilder: (context, index) {
                        final section = manualSections[index];
                        final isSelected = selectedSection == index;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF8B5A84).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                selectedSection = index;
                              });
                            },
                            leading: Icon(
                              section.icon,
                              size: 16,
                              color: isSelected
                                  ? const Color(0xFF8B5A84)
                                  : Colors.grey[600],
                            ),
                            title: Text(
                              section.title,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF8B5A84)
                                    : Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Content Area
          Expanded(
            child: Column(
              children: [
                // Top bar with menu toggle
                if (!isSidebarVisible)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isSidebarVisible = true;
                            });
                          },
                          icon: const Icon(Icons.menu),
                          color: const Color(0xFF8B5A84),
                        ),
                        Text(
                          manualSections[selectedSection].title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B5A84),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the row
                      ],
                    ),
                  ),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: manualSections[selectedSection].gradient,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: manualSections[selectedSection].gradient[1]
                                        .withOpacity(0.3),
                                    spreadRadius: 0,
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      manualSections[selectedSection].icon,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      manualSections[selectedSection].title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Content Card
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    spreadRadius: 0,
                                    blurRadius: 15,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  manualSections[selectedSection].content,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Navigation buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (selectedSection > 0)
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          selectedSection--;
                                        });
                                      },
                                      icon: const Icon(Icons.arrow_back, size: 14),
                                      label: const Text('Previous'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                        foregroundColor: Colors.grey[700],
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        textStyle: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(),
                                if (selectedSection < manualSections.length - 1)
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          selectedSection++;
                                        });
                                      },
                                      icon: const Icon(Icons.arrow_forward, size: 14),
                                      label: const Text('Next'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF8B5A84),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        textStyle: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ManualSection {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final String content;

  ManualSection({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.content,
  });
}
