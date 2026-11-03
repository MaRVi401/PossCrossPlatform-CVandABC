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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artificial Bee Colony (ABC) Bundling'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tombol Trigger Generate
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Paket Promo Lebah ABC',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () => _abcStore.generateBundles(),
            ),
            const SizedBox(height: 20),

            // Konten Daftar Hasil Bundling
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_abcStore.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Koloni lebah sedang mengoptimasi bundle...',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  if (_abcStore.errorMessage != null) {
                    return Center(
                      child: Text(_abcStore.errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center),
                    );
                  }

                  if (_abcStore.bundles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hub_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                              'Belum ada rekomendasi bundle.\nTekan tombol di atas untuk memulai optimasi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: _abcStore.bundles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final bundle = _abcStore.bundles[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hasil Rekomendasi Artificial Bee Colony',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo),
                              ),
                              const Text('Solusi Bundling Diskon Optimal',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              const Divider(height: 20),

                              // List Produk (Fast Moving & Slow Moving)
                              ...bundle.items.map((item) => Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: item.status == 'FAST MOVING'
                                          ? Colors.green.shade50
                                          : Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: item.status == 'FAST MOVING'
                                            ? Colors.green.shade200
                                            : Colors.amber.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color:
                                                    item.status == 'FAST MOVING'
                                                        ? Colors.green.shade700
                                                        : Colors.amber.shade800,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(item.status,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(item.productName,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                            Text(
                                                'Stok: ${item.stock} | Rp ${item.price.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                              const SizedBox(height: 12),

                              // Rincian Harga
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Harga Normal Total:'),
                                        Text(
                                            'Rp ${bundle.normalTotalPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Diskon Lebah:'),
                                        Text(
                                            '- Rp ${bundle.discountAmount.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Harga Paket Promo:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                        Text(
                                            'Rp ${bundle.promoPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigo,
                                                fontSize: 16)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Estimasi Margin Profit
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                        'Estimasi Margin Profit yang Tetap Diperoleh:',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.blue)),
                                    const SizedBox(height: 4),
                                    Text(
                                        'Rp ${bundle.estimatedMargin.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
