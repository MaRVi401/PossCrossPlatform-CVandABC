import 'package:flutter/material.dart';
import '../../../../analytics/presentation/screens/cctv_analytics_screen.dart';
import '../../../../app/di/injection.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../../../auth/presentation/stores/auth_store.dart';
import '../../../katalog/presentation/screens/abc_bundle_screen.dart';
import '../../../katalog/presentation/screens/category_screen.dart';
import '../../../katalog/presentation/screens/product_screen.dart';
import '../../../katalog/presentation/screens/stock_adjustment_screen.dart';
import '../../../reports/presentation/screens/sales_report_screen.dart';
import 'pos_screen.dart';

class PosDashboardScreen extends StatelessWidget {
  const PosDashboardScreen({super.key});

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final authStore = sl<AuthStore>();
    final user = authStore.currentUser;

    const emeraldColor = Color(0xFF10B981);
    const emeraldAccentColor = Color(0xFF34D399);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Dashboard Utama',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, size: 22),
              tooltip: 'Notifikasi',
              onPressed: () {},
            ),
          ),
        ],
      ),
      drawer: const MainDrawer(currentRoute: 'dashboard'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Banner Profil & Status Ringkas
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF312E81).withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white.withAlpha(8),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
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
                                    '${_getTimeBasedGreeting()},',
                                    style: TextStyle(
                                      color: Colors.indigo.shade200,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    user?.name ?? 'Administrator POS',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: emeraldColor.withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: emeraldAccentColor.withAlpha(100),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: emeraldAccentColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user?.roleName ?? 'Admin',
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
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white12, height: 1),
                        const SizedBox(height: 16),

                        // Mini KPI Metrics Summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildKpiItem(
                              label: 'Sistem POS',
                              value: 'Aktif Online',
                              icon: Icons.check_circle_outline_rounded,
                              iconColor: emeraldAccentColor,
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.white12,
                            ),
                            _buildKpiItem(
                              label: 'Visual Vision',
                              value: 'YOLOv8 Ready',
                              icon: Icons.videocam_outlined,
                              iconColor: Colors.cyanAccent,
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.white12,
                            ),
                            _buildKpiItem(
                              label: 'Engine Promo',
                              value: 'ABC Active',
                              icon: Icons.auto_awesome_outlined,
                              iconColor: Colors.amberAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 2. Operasional Kasir & Stok
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Operasional Kasir & Stok',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  '4 Fitur',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
              children: [
                _buildModernMenuCard(
                  context,
                  title: 'Kasir Penjualan',
                  subtitle: 'POS & Pembayaran Direct',
                  icon: Icons.point_of_sale_rounded,
                  gradientColors: [
                    const Color(0xFFEA580C),
                    const Color(0xFFF97316),
                  ],
                  badgeText: 'UTAMA',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PosScreen()),
                    );
                  },
                ),
                _buildModernMenuCard(
                  context,
                  title: 'Manajemen Produk',
                  subtitle: 'Katalog & Update Harga',
                  icon: Icons.inventory_2_rounded,
                  gradientColors: [
                    const Color(0xFF4338CA),
                    const Color(0xFF6366F1),
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductScreen()),
                    );
                  },
                ),
                _buildModernMenuCard(
                  context,
                  title: 'Kategori Barang',
                  subtitle: 'Pengelompokan Katalog',
                  icon: Icons.category_rounded,
                  gradientColors: [
                    const Color(0xFF0D9488),
                    const Color(0xFF14B8A6),
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategoryScreen()),
                    );
                  },
                ),
                _buildModernMenuCard(
                  context,
                  title: 'Penyesuaian Stok',
                  subtitle: 'Stok Opname & In/Out',
                  icon: Icons.tune_rounded,
                  gradientColors: [
                    const Color(0xFF7E22CE),
                    const Color(0xFFA855F7),
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StockAdjustmentScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // 3. Intelligent Analytics (AI)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Intelligent Analytics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: Colors.amber.shade900,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Smart Models',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
              children: [
                _buildModernMenuCard(
                  context,
                  title: 'CCTV Analytics',
                  subtitle: 'Penghitung Pengunjung YOLO',
                  icon: Icons.videocam_rounded,
                  gradientColors: [
                    const Color(0xFF0284C7),
                    const Color(0xFF38BDF8),
                  ],
                  badgeText: 'YOLOv8',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CCTVAnalyticsScreen(),
                      ),
                    );
                  },
                ),
                _buildModernMenuCard(
                  context,
                  title: 'Bundle Promo ABC',
                  subtitle: 'Optimasi Artificial Bee',
                  icon: Icons.auto_awesome_rounded,
                  gradientColors: [
                    const Color(0xFFB45309),
                    const Color(0xFFF59E0B),
                  ],
                  badgeText: 'AI',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ABCBundleScreen(),
                      ),
                    );
                  },
                ),
                _buildModernMenuCard(
                  context,
                  title: 'Laporan Penjualan',
                  subtitle: 'Export PDF & Excel',
                  icon: Icons.analytics_rounded,
                  gradientColors: [
                    const Color(0xFF059669),
                    const Color(0xFF10B981),
                  ],
                  badgeText: 'REPORT',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SalesReportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: gradientColors.first.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors.first.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 24, color: Colors.white),
                    ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: gradientColors.first.withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: gradientColors.first,
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
