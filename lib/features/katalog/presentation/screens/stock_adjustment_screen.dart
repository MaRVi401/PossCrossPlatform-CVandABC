
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../app/di/injection.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../stores/stock_adjustment_store.dart';
import '../stores/product_store.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() =>
      _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState
    extends State<StockAdjustmentScreen> {
  final _adjustmentStore = sl<StockAdjustmentStore>();
  final _productStore = sl<ProductStore>();

  static const Color primaryColor = Color(0xFF1E1B4B);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _adjustmentStore.fetchAdjustments(),
      _productStore.fetchProducts(),
    ]);
  }

  void _showAddAdjustmentModal() {
    final uniqueProducts = <int, dynamic>{};

    for (final product in _productStore.products) {
      uniqueProducts[product.productId] = product;
    }

    final productList = uniqueProducts.values.toList();

    if (productList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data produk belum tersedia.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return _AddAdjustmentSheet(
          products: productList,
          adjustmentStore: _adjustmentStore,
          pageContext: context,
          onSuccess: _refreshData,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Riwayat Penyesuaian Stok',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: _refreshData,
          ),
        ],
      ),

      drawer: const MainDrawer(
        currentRoute: 'stock_adjustment',
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAdjustmentModal,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Atur Stok'),
      ),

      body: Observer(
        builder: (_) {
          if (_adjustmentStore.isLoading &&
              _adjustmentStore.adjustments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          if (_adjustmentStore.adjustments.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height * 0.55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Belum ada riwayat penyesuaian stok',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
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

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: _adjustmentStore.adjustments.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _adjustmentStore.adjustments[index];

                Color badgeColor = Colors.blue;

                if (item.adjustmentType == 'IN') {
                  badgeColor = Colors.green;
                } else if (item.adjustmentType == 'OUT') {
                  badgeColor = Colors.orange;
                } else if (item.adjustmentType == 'CORRECTION') {
                  badgeColor = Colors.purple;
                }

                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Produk dan Badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.productName ??
                                    'Produk #${item.productId}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: badgeColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                item.adjustmentType,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // SKU
                        Text(
                          'SKU: ${item.productSku ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),

                        const Divider(height: 18),

                        // Jumlah dan Pengguna
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 6,
                          children: [
                            Text(
                              'Jumlah: ${item.quantityChanged} Unit',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Oleh: ${item.userName ?? 'Admin'}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Alasan
                        Text(
                          'Alasan: ${item.reason}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
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

// ======================================================
// FORM MODAL PENYESUAIAN STOK
// ======================================================

class _AddAdjustmentSheet extends StatefulWidget {
  final List<dynamic> products;
  final StockAdjustmentStore adjustmentStore;
  final BuildContext pageContext;
  final Future<void> Function() onSuccess;

  const _AddAdjustmentSheet({
    required this.products,
    required this.adjustmentStore,
    required this.pageContext,
    required this.onSuccess,
  });

  @override
  State<_AddAdjustmentSheet> createState() =>
      _AddAdjustmentSheetState();
}

class _AddAdjustmentSheetState
    extends State<_AddAdjustmentSheet> {
  static const Color primaryColor = Color(0xFF1E1B4B);

  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _reasonController = TextEditingController();

  late int selectedProductId;
  String selectedType = 'IN';

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    selectedProductId = widget.products.first.productId;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _saveAdjustment() async {
    if (isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final success =
          await widget.adjustmentStore.createAdjustment(
        productId: selectedProductId,
        adjustmentType: selectedType,
        quantity: int.parse(_qtyController.text.trim()),
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();

        if (widget.pageContext.mounted) {
          widget.onSuccess();

          ScaffoldMessenger.of(widget.pageContext).showSnackBar(
            const SnackBar(
              content: Text(
                'Penyesuaian stok berhasil disimpan!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          isSaving = false;
        });

        final error =
            widget.adjustmentStore.errorMessage ??
                'Gagal menyimpan penyesuaian stok.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Penyesuaian Stok Baru',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Dropdown Produk
              DropdownButtonFormField<int>(
                initialValue: selectedProductId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Pilih Produk',
                  prefixIcon: const Icon(
                    Icons.inventory_2_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: widget.products.map((product) {
                  return DropdownMenuItem<int>(
                    value: product.productId,
                    child: Text(
                      '${product.productName} (Stok: ${product.stockQuantity})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          selectedProductId = value;
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih produk terlebih dahulu';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Dropdown Tipe
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Tipe Penyesuaian',
                  prefixIcon: const Icon(
                    Icons.swap_vert_rounded,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'IN',
                    child: Text(
                      'IN - Stok Masuk / Penambahan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'OUT',
                    child: Text(
                      'OUT - Stok Keluar / Pengurangan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'CORRECTION',
                    child: Text(
                      'CORRECTION - Koreksi Stok',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          selectedType = value;
                        });
                      },
              ),

              const SizedBox(height: 16),

              // Kuantitas
              TextFormField(
                controller: _qtyController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Kuantitas',
                  prefixIcon: const Icon(
                    Icons.numbers_rounded,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  final quantity = int.tryParse(
                    value?.trim() ?? '',
                  );

                  if (quantity == null || quantity <= 0) {
                    return 'Masukkan jumlah yang valid (> 0)';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Alasan
              TextFormField(
                controller: _reasonController,
                enabled: !isSaving,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Alasan / Keterangan',
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        primaryColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isSaving ? null : _saveAdjustment,
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Penyesuaian',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
