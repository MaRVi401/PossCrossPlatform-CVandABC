import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  final String currentRoute;

  const MainDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A), // slate-900 (sesuai tema web)
      child: SafeArea(
        child: Column(
          children: [
            // 1. Header Brand Logo POS ECOSYSTEM
            Container(
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B))), // slate-800
              ),
              child: const Text(
                'POS ECOSYSTEM',
                style: TextStyle(
                  color: Color(0xFF818CF8), // indigo-400
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // 2. Daftar Menu Navigasi
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  // Dashboard
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    route: '/dashboard',
                  ),

                  // Section: Katalog & Stok
                  _buildSectionHeader('KATALOG & STOK'),
                  _buildMenuItem(
                    context,
                    icon: Icons.category_outlined,
                    title: 'Kategori Produk',
                    route: '/categories',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title: 'Data Produk',
                    route: '/products',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.tune_rounded,
                    title: 'Penyesuaian Stok',
                    route: '/stock-adjustments',
                  ),

                  // Section: Transaksi & POS
                  _buildSectionHeader('TRANSAKSI & POS'),
                  _buildMenuItem(
                    context,
                    icon: Icons.point_of_sale_rounded,
                    title: 'Kasir (POS)',
                    route: '/pos',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.assessment_outlined,
                    title: 'Laporan Penjualan',
                    route: '/reports',
                  ),

                  // Section: Smart Optimasi
                  _buildSectionHeader('SMART OPTIMASI'),
                  _buildMenuItem(
                    context,
                    icon: Icons.auto_awesome_rounded,
                    title: 'Smart Bundling (ABC)',
                    route: '/abc',
                    badgeText: 'AI',
                  ),

                  // Section: Manajemen Pengguna
                  _buildSectionHeader('MANAJEMEN PENGGUNA'),
                  _buildMenuItem(
                    context,
                    icon: Icons.people_outline_rounded,
                    title: 'Data Pelanggan',
                    route: '/customers',
                  ),
                ],
              ),
            ),

            // 3. Footer Profile Info & Logout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF4F46E5), // indigo-600
                    radius: 18,
                    child: Text('AY', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ahmad Yassin',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Admin Store',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    tooltip: 'Keluar / Logout',
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B), // slate-500
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    String? badgeText,
  }) {
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, // indigo-600 active
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        horizontalTitleGap: 8,
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: badgeText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1), // indigo-500
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context); // Tutup drawer
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}