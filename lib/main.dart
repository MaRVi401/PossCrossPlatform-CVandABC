import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'analytics/presentation/screens/cctv_analytics_screen.dart';
import 'features/katalog/presentation/screens/category_screen.dart';
import 'features/katalog/presentation/screens/product_screen.dart';
import 'features/katalog/presentation/screens/stock_adjustment_screen.dart';
import 'features/pos/presentation/screens/pos_screen.dart';
import 'features/laporan/presentation/screens/report_screen.dart';
import 'features/abc/prensentation/screens/abc_optimization_screen.dart';
import 'features/pengguna/presentation/screens/customer_screen.dart';

void main() {
  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Ecosystem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      initialRoute: '/dashboard',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const CCTVAnalyticsScreen(),
        '/categories': (context) => const CategoryScreen(),
        '/products': (context) => const ProductScreen(),
        '/stock-adjustments': (context) => const StockAdjustmentScreen(),
        '/pos': (context) => const PosScreen(),
        '/reports': (context) => const ReportScreen(),
        '/abc': (context) => const AbcOptimizationScreen(),
        '/customers': (context) => const CustomerScreen(),
      },
    );
  }
}