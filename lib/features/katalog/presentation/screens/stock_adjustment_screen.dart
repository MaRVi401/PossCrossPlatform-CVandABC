import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../app/di/injection.dart';
import '../stores/stock_adjustment_store.dart';
import '../stores/product_store.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _adjustmentStore = sl<StockAdjustmentStore>();
  final _productStore = sl<ProductStore>();

  @override
  void initState() {
    super.initState();
    _adjustmentStore.fetchAdjustments();
    _productStore.fetchProducts(); // Untuk pilihan produk di form
  }

  void _showAddAdjustmentModal() {
    int? selectedProductId = _productStore.products.isNotEmpty ? _productStore.products.first.productId : null;
    String selectedType = 'IN';
    final qtyController = TextEditingController();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune_rounded, color: Colors.indigo),
                          SizedBox(width: 8),
                          Text(
                            'Penyesuaian Stok Baru',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Dropdown Pilih Produk
                      DropdownButtonFormField<int>(
                        initialValue: selectedProductId,
                        decoration: InputDecoration(
                          labelText: 'Pilih Produk',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _productStore.products.map((p) {
                          return DropdownMenuItem<int>(
                            value: p.productId,
                            child: Text('${p.productName} (Stok: ${p.stockQuantity})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            selectedProductId = val;
                          });
                        },
                        validator: (val) => val == null ? 'Pilih produk terlebih dahulu' : null,
                      ),
                      const SizedBox(height: 16),

                      // Dropdown Tipe Penyesuaian
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: InputDecoration(
                          labelText: 'Tipe Penyesuaian',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'IN', child: Text('IN (Stok Masuk / Penambahan)')),
                          DropdownMenuItem(value: 'OUT', child: Text('OUT (Stok Keluar / Pengurangan)')),
                          DropdownMenuItem(value: 'CORRECTION', child: Text('CORRECTION (Koreksi / Opname Stok)')),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedType = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Jumlah Kuantitas
                      TextFormField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || int.tryParse(v) == null || int.parse(v) <= 0) {
                            return 'Masukkan jumlah angka yang valid (> 0)';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Jumlah Kuantitas',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Alasan Penyesuaian
                      TextFormField(
                        controller: reasonController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Alasan wajib diisi' : null,
                        decoration: InputDecoration(
                          labelText: 'Alasan / Keterangan',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Simpan
                      Observer(
                        builder: (_) {
                          return SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _adjustmentStore.isLoading
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) return;

                                      final success = await _adjustmentStore.createAdjustment(
                                        productId: selectedProductId!,
                                        adjustmentType: selectedType,
                                        quantity: int.parse(qtyController.text.trim()),
                                        reason: reasonController.text.trim(),
                                      );

                                      if (!modalContext.mounted) return;

                                      if (success) {
                                        Navigator.pop(modalContext);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Penyesuaian stok berhasil disimpan!'), backgroundColor: Colors.green),
                                        );
                                      } else if (_adjustmentStore.errorMessage != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(_adjustmentStore.errorMessage!), backgroundColor: Colors.red[700]),
                                        );
                                      }
                                    },
                              child: _adjustmentStore.isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Simpan Penyesuaian'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penyesuaian Stok'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAdjustmentModal,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Atur Stok'),
      ),
      body: Observer(
        builder: (_) {
          if (_adjustmentStore.isLoading && _adjustmentStore.adjustments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_adjustmentStore.adjustments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Belum ada riwayat penyesuaian stok', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _adjustmentStore.fetchAdjustments(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _adjustmentStore.adjustments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _adjustmentStore.adjustments[index];
                Color badgeColor = Colors.blue;
                if (item.adjustmentType == 'IN') badgeColor = Colors.green;
                if (item.adjustmentType == 'OUT') badgeColor = Colors.orange;
                if (item.adjustmentType == 'CORRECTION') badgeColor = Colors.purple;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.productName ?? 'Produk #${item.productId}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                item.adjustmentType,
                                style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('SKU: ${item.productSku ?? '-'}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Jumlah: ${item.quantityChanged} Unit', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text('Oleh: ${item.userName ?? 'Admin'}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Alasan: ${item.reason}', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}