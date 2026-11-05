import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../app/di/injection.dart';
import '../../../katalog/presentation/stores/product_store.dart';
import '../../../katalog/presentation/stores/abc_store.dart';
import '../stores/pos_store.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _productStore = sl<ProductStore>();
  final _abcStore = sl<ABCStore>();
  final _posStore = sl<PosStore>();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productStore.setSearchQuery('');
      _productStore.fetchProducts();
      _abcStore.generateBundles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPaymentModal() {
    int paymentMethodId = 1;
    final paidController =
        TextEditingController(text: _posStore.finalTotal.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final double paidAmount =
                double.tryParse(paidController.text) ?? 0.0;
            final double changeAmount = paidAmount - _posStore.finalTotal;

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Pembayaran Kasir',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: paymentMethodId,
                      decoration: InputDecoration(
                        labelText: 'Metode Pembayaran',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Cash (Tunai)')),
                        DropdownMenuItem(value: 2, child: Text('QRIS')),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Transfer Bank'),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('Credit / Debit Card'),
                        ),
                      ],
                      onChanged: (v) =>
                          setModalState(() => paymentMethodId = v!),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Tagihan:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rp ${_posStore.finalTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: paidController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Uang Diterima (Rp)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                          (double.tryParse(v ?? '') ?? 0) < _posStore.finalTotal
                              ? 'Uang pembayaran kurang!'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: changeAmount >= 0
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            changeAmount >= 0 ? 'Kembalian:' : 'Uang Kurang:',
                            style: TextStyle(
                              color: changeAmount >= 0
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp ${changeAmount.abs().toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: changeAmount >= 0
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Observer(
                      builder: (_) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _posStore.isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;

                                final result = await _posStore.checkout(
                                  paymentMethodId: paymentMethodId,
                                  paidAmount: paidAmount,
                                );

                                if (!mounted) return;

                                if (result != null) {
                                  if (!modalCtx.mounted) return;
                                  Navigator.of(modalCtx).pop();

                                  _productStore.fetchProducts();

                                  if (!mounted) return;

                                  showDialog(
                                    context: context,
                                    builder: (dCtx) => AlertDialog(
                                      title: const Text('Transaksi Berhasil!'),
                                      content: Text(
                                        'Kode Invoice: ${result['invoice_number']}\n'
                                        'Kembalian: Rp ${(result['change_amount'] as num).toStringAsFixed(0)}',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dCtx),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (_posStore.errorMessage != null) {
                                  if (!modalCtx.mounted) return;

                                  ScaffoldMessenger.of(modalCtx).showSnackBar(
                                    SnackBar(
                                      content: Text(_posStore.errorMessage!),
                                      backgroundColor: Colors.red[700],
                                    ),
                                  );
                                }
                              },
                        child: _posStore.isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Selesaikan Transaksi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
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
        title: const Text('Kasir Penjualan (POS)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => _productStore.setSearchQuery(v),
                    decoration: InputDecoration(
                      hintText: 'Cari produk / SKU...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Promo ABC', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    if (_abcStore.bundle != null) {
                      final success = _posStore.applyABCBundle(
                        _abcStore.bundle!,
                        _productStore.products,
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Promo ABC berhasil ditambahkan ke keranjang!',
                            ),
                            backgroundColor: Colors.amber,
                          ),
                        );
                      } else if (_posStore.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_posStore.errorMessage!),
                            backgroundColor: Colors.red[700],
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Rekomendasi promo ABC belum tersedia. Silakan coba lagi.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Catalog Section
                Expanded(
                  flex: 3,
                  child: Observer(
                    builder: (_) {
                      // Status 1: Sedang memuat data
                      if (_productStore.isLoading &&
                          _productStore.products.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text(
                                'Memuat katalog produk...',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }

                      // Status 2: Data kosong / tidak ada produk cocok
                      if (_productStore.filteredProducts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Produk tidak ditemukan',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Muat Ulang Katalog'),
                                onPressed: () {
                                  _searchController.clear();
                                  _productStore.setSearchQuery('');
                                  _productStore.fetchProducts();
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      // Status 3: Menampilkan Grid Produk
                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _productStore.filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _productStore.filteredProducts[index];
                          return InkWell(
                            onTap: () => _posStore.addToCart(product),
                            borderRadius: BorderRadius.circular(12),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: product.stockQuantity < 5
                                            ? Colors.red.shade50
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Stok: ${product.stockQuantity}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: product.stockQuantity < 5
                                              ? Colors.red.shade700
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${product.sellPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Cart Section
                Container(
                  width: 160,
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.all(8),
                  child: Observer(
                    builder: (_) => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Keranjang',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (_posStore.cart.isNotEmpty)
                              InkWell(
                                onTap: () => _posStore.clearCart(),
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: _posStore.cart.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Keranjang Kosong',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _posStore.cart.length,
                                  itemBuilder: (ctx, idx) {
                                    final item = _posStore.cart[idx];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                size: 16,
                                              ),
                                              onPressed: () =>
                                                  _posStore.updateQty(
                                                idx,
                                                -1,
                                              ),
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                size: 16,
                                              ),
                                              onPressed: () =>
                                                  _posStore.updateQty(idx, 1),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                        if (_posStore.discountAmount > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              'Diskon: -Rp ${_posStore.discountAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Text(
                          'Total: Rp ${_posStore.finalTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(36),
                          ),
                          onPressed: _posStore.cart.isEmpty
                              ? null
                              : _showPaymentModal,
                          child: const Text(
                            'Bayar',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
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
}