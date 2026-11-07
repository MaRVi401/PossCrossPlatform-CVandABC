import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../../../katalog/presentation/stores/product_store.dart';
import '../../../katalog/presentation/stores/abc_store.dart';
import 'package:flutter/services.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../stores/pos_store.dart';

const Color _primaryColor = Color(0xFF1E1B4B);
const Color _backgroundColor = Color(0xFFF8FAFC);

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _productStore = sl<ProductStore>();
  final _abcStore = sl<ABCStore>();
  final _posStore = sl<PosStore>();
  final _apiClient = sl<ApiClient>();

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _productStore.setSearchQuery('');
      _refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _productStore.fetchProducts(),
      _abcStore.generateBundles(),
    ]);
  }

  String? _resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return null;

    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    final dioBaseUrl = _apiClient.client.options.baseUrl;
    final uri = Uri.parse(dioBaseUrl);

    final origin =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';

    final cleanPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';

    return '$origin$cleanPath';
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => _PaymentSheet(
        posStore: _posStore,
        onSuccess: _handlePaymentSuccess,
      ),
    );
  }

  void _handlePaymentSuccess(Map<String, dynamic> result) {
    if (!mounted) return;

    _productStore.fetchProducts();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Transaksi Berhasil!'),
        content: Text(
          'Kode Invoice: ${result['invoice_number']}\n'
          'Kembalian: ${CurrencyFormatter.format(result['change_amount'])}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _applyABCPromo() {
    if (_abcStore.bundle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rekomendasi promo ABC belum tersedia. Silakan coba lagi.',
          ),
        ),
      );
      return;
    }

    final success = _posStore.applyABCBundle(
      _abcStore.bundle!,
      _productStore.products,
    );

    if (!mounted) return;

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
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;

          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _productStore.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Cari produk / SKU...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                ),
                label: Text(
                  compact ? 'ABC' : 'Promo ABC',
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: _applyABCPromo,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductCatalog() {
    return Expanded(
      flex: 3,
      child: Observer(
        builder: (_) {
          if (_productStore.isLoading && _productStore.products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Memuat katalog produk...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

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
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.refresh,
                      size: 16,
                    ),
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

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _productStore.filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _productStore.filteredProducts[index];

              final fullImageUrl = _resolveImageUrl(product.imageUrl);

              return InkWell(
                onTap: () => _posStore.addToCart(product),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            fullImageUrl != null
                                ? Image.network(
                                    fullImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 32,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }

                                      return Container(
                                        color: Colors.grey.shade100,
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.indigo.shade50,
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Colors.indigo.shade300,
                                      size: 36,
                                    ),
                                  ),
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: product.stockQuantity < 5
                                      ? Colors.red.withAlpha(230)
                                      : Colors.black.withAlpha(153),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Stok: ${product.stockQuantity}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(product.sellPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                                fontSize: 13,
                              ),
                            ),
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
    );
  }

  Widget _buildCartSection() {
    return Container(
      width: 160,
      color: Colors.white,
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
                    onTap: _posStore.clearCart,
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
                      itemBuilder: (context, index) {
                        final item = _posStore.cart[index];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 32,
                                  ),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 16,
                                  ),
                                  onPressed: () => _posStore.updateQty(
                                    index,
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
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 32,
                                  ),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 16,
                                  ),
                                  onPressed: () => _posStore.updateQty(
                                    index,
                                    1,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 8),
                          ],
                        );
                      },
                    ),
            ),
            if (_posStore.discountAmount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'Diskon: -${CurrencyFormatter.format(_posStore.discountAmount)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              'Total: ${CurrencyFormatter.format(_posStore.finalTotal)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _primaryColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _posStore.cart.isEmpty ? null : _showPaymentModal,
                child: const Text(
                  'Bayar',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Kasir Penjualan (POS)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      drawer: const MainDrawer(currentRoute: 'pos'),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: Row(
              children: [
                _buildProductCatalog(),
                _buildCartSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSheet extends StatefulWidget {
  final PosStore posStore;
  final ValueChanged<Map<String, dynamic>> onSuccess;

  const _PaymentSheet({
    required this.posStore,
    required this.onSuccess,
  });

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class RupiahInputFormatter extends TextInputFormatter {
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

    final formatted = CurrencyFormatter.format(
      int.parse(digits),
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _paidController;

  int _paymentMethodId = 1;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _paidController = TextEditingController(
      text: CurrencyFormatter.format(
        widget.posStore.finalTotal,
      ),
    );
  }

  @override
  void dispose() {
    _paidController.dispose();
    super.dispose();
  }

  double get _paidAmount {
    final digits = _paidController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    return double.tryParse(digits) ?? 0;
  }

  double get _changeAmount => _paidAmount - widget.posStore.finalTotal;

  Future<void> _submitPayment() async {
    if (_isProcessing) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final result = await widget.posStore.checkout(
        paymentMethodId: _paymentMethodId,
        paidAmount: _paidAmount,
      );

      if (!mounted) return;

      if (result != null) {
        Navigator.of(context).pop();
        widget.onSuccess(result);
      } else {
        setState(() => _isProcessing = false);

        final errorMessage = widget.posStore.errorMessage;

        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses pembayaran: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pembayaran Kasir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _paymentMethodId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Metode Pembayaran',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Cash (Tunai)'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('QRIS'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Transfer Bank'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('Credit / Debit Card'),
                  ),
                ],
                onChanged: _isProcessing
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          _paymentMethodId = value;
                        });
                      },
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        CurrencyFormatter.format(widget.posStore.finalTotal),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _paidController,
                enabled: !_isProcessing,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  RupiahInputFormatter(),
                ],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Uang Diterima',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  final amount = _paidAmount;

                  if (amount < widget.posStore.finalTotal) {
                    return 'Uang pembayaran kurang!';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _changeAmount >= 0
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _changeAmount >= 0 ? 'Kembalian:' : 'Uang Kurang:',
                      style: TextStyle(
                        color: _changeAmount >= 0
                            ? Colors.green.shade900
                            : Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        CurrencyFormatter.format(_changeAmount.abs()),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _changeAmount >= 0
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isProcessing ? null : _submitPayment,
                  child: _isProcessing
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
      ),
    );
  }
}
