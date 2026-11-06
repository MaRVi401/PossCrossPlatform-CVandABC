import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../stores/product_store.dart';
import '../stores/category_store.dart';
import '../../data/models/product_model.dart';

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

  /// Membentuk URL gambar lengkap secara dinamis berdasarkan baseUrl di ApiClient
  String? _resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return null;
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    final dioBaseUrl = _apiClient.client.options.baseUrl;
    final uri = Uri.parse(dioBaseUrl);
    final origin = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
    final cleanPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
    return '$origin$cleanPath';
  }

  void _showFormModal({ProductModel? product}) {
    final isEdit = product != null;
    final skuController = TextEditingController(text: product?.sku ?? '');
    final nameController = TextEditingController(text: product?.productName ?? '');
    final buyPriceController = TextEditingController(
      text: product != null ? product.buyPrice.toStringAsFixed(0) : '',
    );
    final sellPriceController = TextEditingController(
      text: product != null ? product.sellPrice.toStringAsFixed(0) : '',
    );
    final stockController = TextEditingController(
      text: product != null ? product.stockQuantity.toString() : '0',
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
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
                      // Header Modal
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isEdit ? Icons.edit_outlined : Icons.add_box_outlined,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEdit ? 'Edit Data Produk' : 'Tambah Produk Baru',
                            style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade900,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Picker Foto Produk
                      Center(
                        child: Stack(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  try {
                                    final picker = ImagePicker();
                                    final pickedFile = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 85,
                                    );

                                    if (pickedFile != null) {
                                      setStateModal(() {
                                        selectedImage = File(pickedFile.path);
                                      });
                                    }
                                  } catch (e) {
                                    if (modalContext.mounted) {
                                      ScaffoldMessenger.of(modalContext).showSnackBar(
                                        SnackBar(
                                          content: Text('Gagal memilih gambar: $e'),
                                          backgroundColor: Colors.red[700],
                                        ),
                                      );
                                    }
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
                                      color: Colors.indigo.shade200,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(10),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: selectedImage != null
                                        ? Image.file(
                                            selectedImage!,
                                            fit: BoxFit.cover,
                                          )
                                        : (existingImageUrl != null)
                                            ? Image.network(
                                                existingImageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.broken_image, size: 28, color: Colors.grey),
                                                    SizedBox(height: 4),
                                                    Text('Gagal muat', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                                  ],
                                                ),
                                              )
                                            : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.add_a_photo_outlined, size: 30, color: Colors.indigo.shade400),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    'Upload Foto',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.indigo.shade700,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dropdown Kategori
                      DropdownButtonFormField<int>(
                        initialValue: selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Kategori Produk',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        items: _categoryStore.categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat.categoryId,
                            child: Text(cat.categoryName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setStateModal(() {
                            selectedCategoryId = val;
                          });
                        },
                        validator: (val) => val == null ? 'Pilih kategori terlebih dahulu' : null,
                      ),
                      const SizedBox(height: 16),

                      // Input SKU & Nama Produk
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: skuController,
                              validator: (v) => v == null || v.trim().isEmpty ? 'SKU wajib diisi' : null,
                              decoration: InputDecoration(
                                labelText: 'SKU / Kode',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: nameController,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                              decoration: InputDecoration(
                                labelText: 'Nama Produk',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Input Harga Beli & Jual
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: buyPriceController,
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || double.tryParse(v) == null ? 'Harga tidak valid' : null,
                              decoration: InputDecoration(
                                labelText: 'Harga Beli (Rp)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: sellPriceController,
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || double.tryParse(v) == null ? 'Harga tidak valid' : null,
                              decoration: InputDecoration(
                                labelText: 'Harga Jual (Rp)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Jumlah Stok
                      TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Stok tidak valid' : null,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Stok Tersedia',
                          prefixIcon: const Icon(Icons.inventory_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Simpan Modal
                      Observer(
                        builder: (_) {
                          return SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _productStore.isLoading
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) return;

                                      final success = isEdit
                                          ? await _productStore.updateProduct(
                                              productId: product.productId,
                                              categoryId: selectedCategoryId!,
                                              sku: skuController.text.trim(),
                                              productName: nameController.text.trim(),
                                              buyPrice: double.parse(buyPriceController.text.trim()),
                                              sellPrice: double.parse(sellPriceController.text.trim()),
                                              stockQuantity: int.parse(stockController.text.trim()),
                                              imageFile: selectedImage,
                                            )
                                          : await _productStore.addProduct(
                                              categoryId: selectedCategoryId!,
                                              sku: skuController.text.trim(),
                                              productName: nameController.text.trim(),
                                              buyPrice: double.parse(buyPriceController.text.trim()),
                                              sellPrice: double.parse(sellPriceController.text.trim()),
                                              stockQuantity: int.parse(stockController.text.trim()),
                                              imageFile: selectedImage,
                                            );

                                      if (!modalContext.mounted) return;

                                      if (success) {
                                        Navigator.pop(modalContext);
                                        ScaffoldMessenger.of(modalContext).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isEdit
                                                  ? 'Produk berhasil diperbarui!'
                                                  : 'Produk berhasil ditambahkan!',
                                            ),
                                            backgroundColor: Colors.green[700],
                                          ),
                                        );
                                      } else if (_productStore.errorMessage != null) {
                                        ScaffoldMessenger.of(modalContext).showSnackBar(
                                          SnackBar(
                                            content: Text(_productStore.errorMessage!),
                                            backgroundColor: Colors.red[700],
                                          ),
                                        );
                                      }
                                    },
                              child: _productStore.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
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
    );
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Produk'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus produk "${product.productName}"?'),
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
              final success = await _productStore.deleteProduct(product.productId);

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produk berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (_productStore.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_productStore.errorMessage!),
                    backgroundColor: Colors.red[700],
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _showFormModal(),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text(
                'Tambah',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bar Pencarian
          Container(
            color: Colors.indigo,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _productStore.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Cari nama produk / SKU...',
                prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _productStore.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Daftar Produk
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
                        Text('Memuat katalog produk...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                if (_productStore.filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _productStore.fetchProducts(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _productStore.filteredProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = _productStore.filteredProducts[index];
                      final fullImageUrl = _resolveImageUrl(product.imageUrl);
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
                                  // Thumbnail Foto Produk
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: fullImageUrl != null
                                        ? Image.network(
                                            fullImageUrl,
                                            width: 68,
                                            height: 68,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 68,
                                              height: 68,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                width: 68,
                                                height: 68,
                                                color: Colors.grey.shade100,
                                                child: const Center(
                                                  child: SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            width: 68,
                                            height: 68,
                                            color: Colors.indigo.shade50,
                                            child: Icon(
                                              Icons.inventory_2_outlined,
                                              color: Colors.indigo.shade300,
                                              size: 32,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Detail Teks Informasi Produk
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(
                                              'Rp ${product.sellPrice.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigo,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isLowStock
                                                    ? Colors.red.shade50
                                                    : Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Stok: ${product.stockQuantity}',
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

                                  // Tombol Edit & Hapus
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.indigo, size: 20),
                                        onPressed: () => _showFormModal(product: product),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                        onPressed: () => _confirmDelete(product),
                                      ),
                                    ],
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
}