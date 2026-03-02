import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/history_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/history_screen.dart';
import 'screens/trading_account_screen.dart';
import 'screens/trading_account_result_screen.dart';
import 'screens/profit_loss_screen.dart';
import 'screens/profit_loss_result_screen.dart';
import 'screens/financial_position_screen.dart';
import 'screens/financial_position_result_screen.dart';
import 'screens/business_accounting_screen.dart';
import 'screens/business_accounting_result_screen.dart';
import 'screens/report_analysis_screen.dart';
import 'screens/about_us_screen.dart';
import 'screens/help_screen.dart';
import 'screens/user_manual_screen.dart';

void main() {
  runApp(const AccountingCalculatorApp());
}

class AccountingCalculatorApp extends StatelessWidget {
  const AccountingCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Accounting Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFF8B5A84, {
            50: const Color(0xFFF3E5F5),
            100: const Color(0xFFE1BEE7),
            200: const Color(0xFFCE93D8),
            300: const Color(0xFFBA68C8),
            400: const Color(0xFFAB47BC),
            500: const Color(0xFF8B5A84),
            600: const Color(0xFF8E24AA),
            700: const Color(0xFF7B1FA2),
            800: const Color(0xFF6A1B9A),
            900: const Color(0xFF4A148C),
          }),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5A84)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5A84),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8B5A84),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isAuthenticated) {
              return const DashboardScreen();
            }
            return const LoginScreen();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/history': (context) => const HistoryScreen(),
          '/trading-account': (context) => const TradingAccountScreen(),
          '/trading-account-result': (context) =>
              const TradingAccountResultScreen(),
          '/profit-loss': (context) => const ProfitLossScreen(),
          '/profit-loss-result': (context) => const ProfitLossResultScreen(),
          '/financial-position': (context) => const FinancialPositionScreen(),
          '/financial-position-result': (context) =>
              const FinancialPositionResultScreen(),
          '/business-accounting': (context) => const BusinessAccountingScreen(),
          '/business-accounting-result': (context) =>
              const BusinessAccountingResultScreen(),
          '/report-analysis': (context) => const ReportAnalysisScreen(),
          '/about-us': (context) => const AboutUsScreen(),
          '/help': (context) => const HelpScreen(),
          '/user-manual': (context) => const UserManualScreen(),
        },
      ),
    );
  }
}
