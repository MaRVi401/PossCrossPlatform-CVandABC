import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../stores/product_store.dart';
import '../stores/category_store.dart';
import '../../data/models/product_model.dart';

// ============================================================
// FORMATTER INPUT RUPIAH
// ============================================================

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(digits);

    if (number == null) return oldValue;

    final formatted = CurrencyFormatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ============================================================
// FORMATTER STOK: 1000 MENJADI 1.000
// ============================================================

class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(digits);

    if (number == null) return oldValue;

    final formatted = NumberFormat.decimalPattern('id_ID').format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ============================================================
// PRODUCT SCREEN
// ============================================================

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _productStore = sl<ProductStore>();
  final _categoryStore = sl<CategoryStore>();
  final _apiClient = sl<ApiClient>();

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productStore.fetchProducts();
    _categoryStore.fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // KONVERSI INPUT MENJADI ANGKA
  // ==========================================================

  double _parseRupiah(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digits) ?? 0;
  }

  int _parseStock(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  String _formatStock(int value) {
    return NumberFormat.decimalPattern('id_ID').format(value);
  }

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
          backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        ),
      );
  }

  // ==========================================================
  // RESOLVE URL GAMBAR
  // ==========================================================

  String? _resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }

    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    final baseUrl = _apiClient.client.options.baseUrl;
    final uri = Uri.tryParse(baseUrl);

    if (uri == null || uri.host.isEmpty) {
      return null;
    }

    final origin =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';

    final cleanPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';

    return '$origin$cleanPath';
  }

  // ==========================================================
  // FORM TAMBAH DAN EDIT PRODUK
  // ==========================================================

  void _showFormModal({ProductModel? product}) {
    final isEdit = product != null;

    final skuController = TextEditingController(
      text: product?.sku ?? '',
    );

    final nameController = TextEditingController(
      text: product?.productName ?? '',
    );

    final buyPriceController = TextEditingController(
      text: product == null ? '' : CurrencyFormatter.format(product.buyPrice),
    );

    final sellPriceController = TextEditingController(
      text: product == null ? '' : CurrencyFormatter.format(product.sellPrice),
    );

    final stockController = TextEditingController(
      text: product == null ? '0' : _formatStock(product.stockQuantity),
    );

    int? selectedCategoryId = product?.categoryId ??
        (_categoryStore.categories.isNotEmpty
            ? _categoryStore.categories.first.categoryId
            : null);

    File? selectedImage;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setStateModal) {
            final existingImageUrl = _resolveImageUrl(product?.imageUrl);

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
                      // HEADER
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isEdit
                                  ? Icons.edit_outlined
                                  : Icons.add_box_outlined,
                              color: const Color(0xFF1E1B4B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEdit
                                  ? 'Edit Data Produk'
                                  : 'Tambah Produk Baru',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(modalContext),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // FOTO PRODUK
                      Center(
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () async {
                                try {
                                  final picker = ImagePicker();

                                  final pickedFile = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 85,
                                  );

                                  if (pickedFile != null &&
                                      modalContext.mounted) {
                                    setStateModal(() {
                                      selectedImage = File(pickedFile.path);
                                    });
                                  }
                                } catch (e) {
                                  _showMessage(
                                    'Gagal memilih gambar: $e',
                                    isError: true,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        const Color(0xFF1E1B4B).withAlpha(70),
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: selectedImage != null
                                      ? Image.file(
                                          selectedImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : existingImageUrl != null
                                          ? Image.network(
                                              existingImageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.broken_image,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                            )
                                          : const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add_a_photo_outlined,
                                                  size: 30,
                                                  color: Color(0xFF1E1B4B),
                                                ),
                                                SizedBox(height: 6),
                                                Text(
                                                  'Upload Foto',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                ),
                              ),
                            ),
                            if (selectedImage != null)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setStateModal(() {
                                      selectedImage = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // KATEGORI
                      DropdownButtonFormField<int>(
                        initialValue: selectedCategoryId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Kategori Produk',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _categoryStore.categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.categoryId,
                            child: Text(
                              category.categoryName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateModal(() {
                            selectedCategoryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih kategori terlebih dahulu';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // SKU DAN NAMA
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: skuController,
                              decoration: InputDecoration(
                                labelText: 'SKU / Kode',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'SKU wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Nama Produk',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // HARGA BELI DAN JUAL
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: buyPriceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                RupiahInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Harga Beli',
                                prefixIcon: const Icon(
                                  Icons.payments_outlined,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Harga wajib diisi';
                                }
                                if (_parseRupiah(value) <= 0) {
                                  return 'Harga tidak valid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: sellPriceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                RupiahInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Harga Jual',
                                prefixIcon: const Icon(
                                  Icons.payments_outlined,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Harga wajib diisi';
                                }
                                if (_parseRupiah(value) <= 0) {
                                  return 'Harga tidak valid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // STOK
                      TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          ThousandsInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Jumlah Stok Tersedia',
                          prefixIcon: const Icon(
                            Icons.inventory_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Stok wajib diisi';
                          }

                          final stock = _parseStock(value);

                          if (stock < 0) {
                            return 'Stok tidak valid';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // TOMBOL SIMPAN
                      Observer(
                        builder: (_) {
                          final isLoading = _productStore.isLoading;

                          return SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E1B4B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      if (selectedCategoryId == null) {
                                        _showMessage(
                                          'Kategori belum dipilih',
                                          isError: true,
                                        );
                                        return;
                                      }

                                      // Konversi semua input ke angka murni.
                                      final double buyPrice = _parseRupiah(
                                        buyPriceController.text,
                                      );

                                      final double sellPrice = _parseRupiah(
                                        sellPriceController.text,
                                      );

                                      final int stockQuantity = _parseStock(
                                        stockController.text,
                                      );

                                      try {
                                        final bool success;

                                        if (isEdit) {
                                          success =
                                              await _productStore.updateProduct(
                                            productId: product.productId,
                                            categoryId: selectedCategoryId!,
                                            sku: skuController.text.trim(),
                                            productName:
                                                nameController.text.trim(),
                                            buyPrice: buyPrice,
                                            sellPrice: sellPrice,
                                            stockQuantity: stockQuantity,
                                            imageFile: selectedImage,
                                          );
                                        } else {
                                          success =
                                              await _productStore.addProduct(
                                            categoryId: selectedCategoryId!,
                                            sku: skuController.text.trim(),
                                            productName:
                                                nameController.text.trim(),
                                            buyPrice: buyPrice,
                                            sellPrice: sellPrice,
                                            stockQuantity: stockQuantity,
                                            imageFile: selectedImage,
                                          );
                                        }

                                        if (!mounted || !modalContext.mounted) {
                                          return;
                                        }

                                        if (success) {
                                          Navigator.pop(modalContext);

                                          _showMessage(
                                            isEdit
                                                ? 'Produk berhasil diperbarui!'
                                                : 'Produk berhasil ditambahkan!',
                                          );
                                        } else {
                                          final error =
                                              _productStore.errorMessage;

                                          _showMessage(
                                            error?.isNotEmpty == true
                                                ? error!
                                                : 'Gagal menyimpan produk. Periksa data dan koneksi server.',
                                            isError: true,
                                          );
                                        }
                                      } catch (e) {
                                        _showMessage(
                                          'Terjadi kesalahan saat menyimpan produk: $e',
                                          isError: true,
                                        );
                                      }
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isEdit
                                          ? 'Simpan Perubahan'
                                          : 'Tambah Produk',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
    ).whenComplete(() {
      skuController.dispose();
      nameController.dispose();
      buyPriceController.dispose();
      sellPriceController.dispose();
      stockController.dispose();
    });
  }

  // ==========================================================
  // HAPUS PRODUK
  // ==========================================================

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 8),
              Text('Hapus Produk'),
            ],
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus produk "${product.productName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  final success = await _productStore.deleteProduct(
                    product.productId,
                  );

                  if (!mounted) return;

                  if (success) {
                    _showMessage('Produk berhasil dihapus');
                  } else {
                    _showMessage(
                      _productStore.errorMessage ?? 'Gagal menghapus produk',
                      isError: true,
                    );
                  }
                } catch (e) {
                  _showMessage(
                    'Gagal menghapus produk: $e',
                    isError: true,
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // BUILD SCREEN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Manajemen Produk',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: () {
              _productStore.fetchProducts();
              _categoryStore.fetchCategories();
            },
          ),
        ],
      ),
      drawer: const MainDrawer(
        currentRoute: 'product',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormModal(),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
      body: Column(
        children: [
          // PENCARIAN
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _productStore.setSearchQuery(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Cari nama produk / SKU...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF1E1B4B),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _productStore.setSearchQuery('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // DAFTAR PRODUK
          Expanded(
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
                          style: TextStyle(color: Colors.grey),
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
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await _productStore.fetchProducts();
                    await _categoryStore.fetchCategories();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: _productStore.filteredProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = _productStore.filteredProducts[index];

                      final imageUrl = _resolveImageUrl(product.imageUrl);

                      final isLowStock = product.stockQuantity < 5;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showFormModal(product: product),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // FOTO
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            width: 68,
                                            height: 68,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) {
                                              return _imagePlaceholder();
                                            },
                                          )
                                        : _imagePlaceholder(),
                                  ),

                                  const SizedBox(width: 14),

                                  // DETAIL PRODUK
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.productName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'SKU: ${product.sku} • ${product.categoryName ?? 'Tanpa Kategori'}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              CurrencyFormatter.format(
                                                product.sellPrice,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E1B4B),
                                                fontSize: 14,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isLowStock
                                                    ? Colors.red.shade50
                                                    : Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Stok: ${_formatStock(product.stockQuantity)}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isLowStock
                                                      ? Colors.red.shade700
                                                      : Colors.green.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // TOMBOL EDIT DAN HAPUS
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Color(0xFF1E1B4B),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _showFormModal(product: product);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _confirmDelete(product);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 68,
      height: 68,
      color: const Color(0xFFEEF2FF),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Color(0xFF1E1B4B),
        size: 32,
      ),
    );
  }
}
