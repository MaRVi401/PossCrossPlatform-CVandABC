import 'package:flutter/material.dart';
import '../../analytics/presentation/screens/cctv_analytics_screen.dart';
import '../../app/di/injection.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/stores/auth_store.dart';
import '../../features/katalog/presentation/screens/abc_bundle_screen.dart';
import '../../features/katalog/presentation/screens/category_screen.dart';
import '../../features/katalog/presentation/screens/product_screen.dart';
import '../../features/katalog/presentation/screens/stock_adjustment_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/reports/presentation/screens/sales_report_screen.dart';

class MainDrawer extends StatelessWidget {
  final String currentRoute;

  const MainDrawer({
    super.key,
    this.currentRoute = 'dashboard',
  });

  @override
  Widget build(BuildContext context) {
    final authStore = sl<AuthStore>();
    final user = authStore.currentUser;

    const emeraldColor = Color(0xFF10B981);
    const emeraldAccentColor = Color(0xFF34D399);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 1. Drawer Header Profil Premium
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.amber.shade400,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Text(
                          (user?.name.isNotEmpty == true)
                              ? user!.name[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Admin POS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'admin@pos.com',
                            style: TextStyle(
                              color: Colors.indigo.shade200,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: emeraldColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: emeraldAccentColor.withAlpha(100),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: emeraldAccentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Role: ${user?.roleName ?? 'Administrator'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Daftar Menu Navigasi (Grouped Sections)
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                _buildSectionHeader('UTAMA'),
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  title: 'Dashboard Utama',
                  isSelected: currentRoute == 'dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'dashboard') {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildSectionHeader('OPERASIONAL KASIR & STOK'),
                _buildDrawerItem(
                  context,
                  icon: Icons.point_of_sale_outlined,
                  activeIcon: Icons.point_of_sale_rounded,
                  title: 'Kasir Penjualan (POS)',
                  isSelected: currentRoute == 'pos',
                  activeColor: const Color(0xFFEA580C),
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'pos') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PosScreen()),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  title: 'Manajemen Produk',
                  isSelected: currentRoute == 'product',
                  activeColor: const Color(0xFF4338CA),
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'product') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductScreen(),
                        ),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.category_outlined,
                  activeIcon: Icons.category_rounded,
                  title: 'Kategori Barang',
                  isSelected: currentRoute == 'category',
                  activeColor: const Color(0xFF0D9488),
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'category') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoryScreen(),
                        ),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.tune_outlined,
                  activeIcon: Icons.tune_rounded,
                  title: 'Penyesuaian Stok',
                  isSelected: currentRoute == 'stock_adjustment',
                  activeColor: const Color(0xFF7E22CE),
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'stock_adjustment') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StockAdjustmentScreen(),
                        ),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics_rounded,
                  title: 'Laporan Penjualan',
                  isSelected: currentRoute == 'sales_report',
                  activeColor: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'sales_report') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SalesReportScreen()),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildSectionHeader('INTELLIGENT ANALYTICS'),
                _buildDrawerItem(
                  context,
                  icon: Icons.videocam_outlined,
                  activeIcon: Icons.videocam_rounded,
                  title: 'CCTV Analytics (YOLOv8)',
                  isSelected: currentRoute == 'cctv',
                  activeColor: const Color(0xFF0284C7),
                  badgeText: 'CV',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'cctv') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CCTVAnalyticsScreen(),
                        ),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome_rounded,
                  title: 'Bundle Promo (ABC)',
                  isSelected: currentRoute == 'abc',
                  activeColor: const Color(0xFFB45309),
                  badgeText: 'AI',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'abc') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ABCBundleScreen(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // 3. Footer Tombol Keluar (Logout)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Material(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _confirmLogout(context, authStore),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Text(
                        'Keluar Sesi (Logout)',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Label Judul Sub-Seksi Menu
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade400,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// Item Menu Navigasi Modern
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required bool isSelected,
    Color activeColor = const Color(0xFF312E81),
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: isSelected ? activeColor.withAlpha(20) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeColor : Colors.grey.shade600,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? activeColor : Colors.grey.shade800,
                    ),
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: activeColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: activeColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Dialog Konfirmasi Logout
  void _confirmLogout(BuildContext context, AuthStore authStore) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Konfirmasi Logout'),
          ],
        ),
        content:
            const Text('Apakah Anda yakin ingin keluar dari akun kasir ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authStore.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }
}
