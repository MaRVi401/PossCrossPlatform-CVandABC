import 'package:flutter/material.dart';
import '../../../../analytics/presentation/screens/cctv_analytics_screen.dart';
import '../../../../app/di/injection.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/stores/auth_store.dart';
import '../../../katalog/presentation/screens/category_screen.dart';

class PosDashboardScreen extends StatelessWidget {
  const PosDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authStore = sl<AuthStore>();
    final user = authStore.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard POS & Analytics'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              accountName: Text(user?.name ?? 'Admin POS'),
              accountEmail: Text(user?.email ?? 'admin@pos.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (user?.name.isNotEmpty == true)
                      ? user!.name[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('CCTV Analytics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CCTVAnalyticsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Keluar',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                await authStore.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang, ${user?.name ?? 'Admin'}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${user?.roleName ?? 'Admin / Kasir'}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'CCTV Analytics',
                    subtitle: 'Real-time Visitor Analytics',
                    icon: Icons.videocam_rounded,
                    color: Colors.blue.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CCTVAnalyticsScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Kasir POS',
                    subtitle: 'Kelola Transaksi',
                    icon: Icons.point_of_sale_rounded,
                    color: Colors.orange.shade800,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Modul POS akan dibuat selanjutnya')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Kategori Produk',
                    subtitle: 'Kelola Jenis Produk',
                    icon: Icons.category_rounded,
                    color: Colors.teal.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CategoryScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
