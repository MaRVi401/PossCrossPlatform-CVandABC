import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../app/di/injection.dart';
import '../stores/abc_store.dart';

class ABCBundleScreen extends StatefulWidget {
  const ABCBundleScreen({super.key});

  @override
  State<ABCBundleScreen> createState() => _ABCBundleScreenState();
}

class _ABCBundleScreenState extends State<ABCBundleScreen> {
  final _abcStore = sl<ABCStore>();

  @override
  void initState() {
    super.initState();
    _abcStore.generateBundles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Optimasi Promo (ABC)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Observer(
        builder: (_) {
          if (_abcStore.isLoading && _abcStore.bundle == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('🐝 Lebah sedang mencari solusi swarming...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _abcStore.generateBundles(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(10)),
                                  child: const Text('🐝', style: TextStyle(fontSize: 20)),
                                ),
                                const SizedBox(width: 10),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Intelligence Swarm Engine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('Modul Optimasi Paket Promo', style: TextStyle(fontSize: 11, color: Colors.amber)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Menggunakan Artificial Bee Colony (ABC) untuk menganalisis produk fast-moving dan slow-moving secara otomatis.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(_abcStore.isLoading ? 'Lebah Mencari Solusi...' : 'Regenerasi Paket Promo'),
                          onPressed: _abcStore.isLoading ? null : () => _abcStore.generateBundles(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_abcStore.errorMessage != null && _abcStore.errorMessage!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                      child: Text(_abcStore.errorMessage!, style: TextStyle(color: Colors.red.shade800, fontSize: 12)),
                    ),

                  if (_abcStore.bundle != null) ...[
                    // Kombinasi Produk Fast & Slow Moving
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('KOMBINASI PRODUK HASIL SWARM INTELLIGENCE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 12),

                          // Produk Fast Moving
                          _buildProductCard(
                            title: 'PRODUK PENOPANG',
                            badge: 'FAST MOVING',
                            badgeColor: Colors.green,
                            productName: _abcStore.bundle?.fastProduct?.productName ?? '-',
                            sellPrice: _abcStore.bundle?.fastProduct?.sellPrice ?? 0,
                            stock: _abcStore.bundle?.fastProduct?.stock ?? 0,
                          ),
                          const SizedBox(height: 12),

                          // Produk Slow Moving
                          _buildProductCard(
                            title: 'PRODUK CUCI GUDANG',
                            badge: 'SLOW MOVING',
                            badgeColor: Colors.amber.shade800,
                            productName: _abcStore.bundle?.slowProduct?.productName ?? '-',
                            sellPrice: _abcStore.bundle?.slowProduct?.sellPrice ?? 0,
                            stock: _abcStore.bundle?.slowProduct?.stock ?? 0,
                          ),
                          const SizedBox(height: 16),

                          // Rincian Kalkulasi Harga
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.indigo.shade100),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Harga Normal Kedua Produk:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text('Rp ${_abcStore.bundle!.normalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Potongan Diskon Lebah ABC (${_abcStore.bundle!.discountRate}):', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text('- Rp ${_abcStore.bundle!.discountAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Harga Bundling Promo Kasir:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('Rp ${_abcStore.bundle!.promoPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Analisis Fitnes Diskon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('ANALISIS FITNES DISKON', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.indigo.shade50, Colors.purple.shade50]),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.indigo.shade100),
                            ),
                            child: Column(
                              children: [
                                const Text('ESTIMASI MARGIN KEUNTUNGAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                const SizedBox(height: 6),
                                Text(
                                  'Rp ${_abcStore.bundle!.estimatedProfit.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                ),
                                const SizedBox(height: 4),
                                const Text('Dihitung dari Harga Promo - Total Harga Beli Modal', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Paket berhasil diterapkan ke Kasir POS!'), backgroundColor: Colors.green),
                              );
                            },
                            child: const Text('Terapkan Paket Ke Kasir (POS) →', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required String productName,
    required double sellPrice,
    required int stock,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Harga Jual Normal', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('Rp ${sellPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Sisa Stok', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('$stock Unit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: badgeColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}