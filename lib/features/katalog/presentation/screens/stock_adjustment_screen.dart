
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../stores/stock_adjustment_store.dart';
import '../stores/product_store.dart';

// ============================================================
// FORMATTER ANGKA RIBUAN
// Contoh: 1000 menjadi 1.000
// ============================================================

class StockThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(digits);

    if (number == null) {
      return oldValue;
    }

    final formatted = NumberFormat.decimalPattern('id_ID').format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

// ============================================================
// STOCK ADJUSTMENT SCREEN
// ============================================================

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

  // ==========================================================
  // REFRESH DATA
  // ==========================================================

  Future<void> _refreshData() async {
    try {
      await Future.wait([
        _adjustmentStore.fetchAdjustments(),
        _productStore.fetchProducts(),
      ]);
    } catch (e) {
      if (mounted) {
        _showMessage(
          'Gagal memuat data: $e',
          isError: true,
        );
      }
    }
  }

  // ==========================================================
  // FORMAT STOK
  // ==========================================================

  String _formatStock(int value) {
    return NumberFormat.decimalPattern('id_ID').format(value);
  }

  // ==========================================================
  // NOTIFIKASI
  // ==========================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
        ),
      );
  }

  // ==========================================================
  // MODAL TAMBAH PENYESUAIAN STOK
  // ==========================================================

  void _showAddAdjustmentModal() {
    // Menghindari produk duplikat berdasarkan ID.
    final Map<int, dynamic> uniqueProducts = {};

    for (final product in _productStore.products) {
      uniqueProducts[product.productId] = product;
    }

    final productList = uniqueProducts.values.toList();

    if (productList.isEmpty) {
      _showMessage(
        'Data produk belum tersedia. Silakan refresh terlebih dahulu.',
        isError: true,
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
          formatStock: _formatStock,
          onSuccess: () async {
            await _refreshData();
          },
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

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
                    height: MediaQuery.of(context).size.height * 0.55,
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

                Color badgeColor;

                switch (item.adjustmentType) {
                  case 'IN':
                    badgeColor = Colors.green;
                    break;
                  case 'OUT':
                    badgeColor = Colors.orange;
                    break;
                  case 'CORRECTION':
                    badgeColor = Colors.purple;
                    break;
                  default:
                    badgeColor = Colors.blue;
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
                        // NAMA PRODUK DAN BADGE
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

                        // JUMLAH DAN PENGGUNA
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 6,
                          children: [
                            Text(
                              'Jumlah: ${_formatStock(item.quantityChanged.abs())} Unit',
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

                        // ALASAN
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

// ============================================================
// FORM MODAL PENYESUAIAN STOK
// ============================================================

class _AddAdjustmentSheet extends StatefulWidget {
  final List<dynamic> products;
  final StockAdjustmentStore adjustmentStore;
  final Future<void> Function() onSuccess;
  final String Function(int) formatStock;

  const _AddAdjustmentSheet({
    required this.products,
    required this.adjustmentStore,
    required this.onSuccess,
    required this.formatStock,
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

  // ==========================================================
  // PARSE JUMLAH STOK
  // Contoh: "1.000" menjadi 1000
  // ==========================================================

  int _parseQuantity(String value) {
    final digits = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    return int.tryParse(digits) ?? 0;
  }

  // ==========================================================
  // SIMPAN PENYESUAIAN STOK
  // ==========================================================

  Future<void> _saveAdjustment() async {
    if (isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = _parseQuantity(_qtyController.text);

    if (quantity <= 0) {
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
        quantity: quantity,
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        // Tutup modal terlebih dahulu.
        Navigator.of(context).pop();

        // Refresh data dan tampilkan notifikasi.
        await widget.onSuccess();

        if (widget.products.isNotEmpty) {
          // Tidak ada operasi tambahan.
        }

        // Gunakan messenger sebelum modal ditutup melalui root navigator
        // dengan menyimpan messenger pada saat proses berlangsung.
        // Notifikasi ditampilkan dari halaman melalui callback.
      } else {
        setState(() {
          isSaving = false;
        });

        final error = widget.adjustmentStore.errorMessage;

        _showError(
          error?.isNotEmpty == true
              ? error!
              : 'Gagal menyimpan penyesuaian stok.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      _showError('Terjadi kesalahan saat menyimpan: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
        ),
      );
  }

  // ==========================================================
  // BUILD FORM
  // ==========================================================

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
              // HEADER
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
                  IconButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // PILIH PRODUK
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
                      '${product.productName} (Stok: ${widget.formatStock(product.stockQuantity)})',
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

              // TIPE PENYESUAIAN
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

              // JUMLAH STOK
              TextFormField(
                controller: _qtyController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  StockThousandsInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Jumlah Kuantitas',
                  hintText: 'Contoh: 1.000',
                  prefixIcon: const Icon(
                    Icons.numbers_rounded,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jumlah stok wajib diisi';
                  }

                  final quantity = _parseQuantity(value);

                  if (quantity <= 0) {
                    return 'Masukkan jumlah yang valid (> 0)';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ALASAN
              TextFormField(
                controller: _reasonController,
                enabled: !isSaving,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Alasan / Keterangan',
                  hintText: 'Contoh: Pembelian barang dari supplier',
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

              // TOMBOL SIMPAN
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
