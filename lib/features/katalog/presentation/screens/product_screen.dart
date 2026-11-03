import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/di/injection.dart';
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

  void _showFormModal({ProductModel? product}) {
    final isEdit = product != null;
    final skuController = TextEditingController(text: product?.sku ?? '');
    final nameController = TextEditingController(text: product?.productName ?? '');
    final buyPriceController = TextEditingController(text: product?.buyPrice.toString() ?? '');
    final sellPriceController = TextEditingController(text: product?.sellPrice.toString() ?? '');
    final stockController = TextEditingController(text: product?.stockQuantity.toString() ?? '0');
    
    int? selectedCategoryId = product?.categoryId ?? (_categoryStore.categories.isNotEmpty ? _categoryStore.categories.first.categoryId : null);
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
                      Row(
                        children: [
                          Icon(isEdit ? Icons.edit_outlined : Icons.add_box_outlined, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Text(
                            isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
                            style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade900,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Area Pilih Gambar dengan Try-Catch Aman
                      Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              try {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 80,
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
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.indigo.shade300, width: 1.5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: selectedImage != null
                                    ? Image.file(
                                        selectedImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : (product?.imageUrl != null && product!.imageUrl!.isNotEmpty)
                                        ? Image.network(
                                            'http://10.0.2.2:8000${product.imageUrl}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.broken_image, size: 30, color: Colors.grey),
                                                SizedBox(height: 4),
                                                Text('Gagal muat', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                              ],
                                            ),
                                          )
                                        : const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_a_photo, size: 32, color: Colors.indigo),
                                              SizedBox(height: 4),
                                              Text('Pilih Foto', style: TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dropdown Kategori
                      DropdownButtonFormField<int>(
                        initialValue: selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

                      // SKU & Nama Produk
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

                      // Harga Beli & Jual
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: buyPriceController,
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || double.tryParse(v) == null ? 'Tidak valid' : null,
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
                              validator: (v) => v == null || double.tryParse(v) == null ? 'Tidak valid' : null,
                              decoration: InputDecoration(
                                labelText: 'Harga Jual (Rp)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stok
                      TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Stok tidak valid' : null,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Stok',
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
                              onPressed: _productStore.isLoading
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

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

                                      if (!modalContext.mounted) {
                                        return;
                                      }

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
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Produk'),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await _productStore.deleteProduct(product.productId);
              
              if (!mounted) {
                return;
              }

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produk berhasil dihapus'), backgroundColor: Colors.green),
                );
              } else if (_productStore.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_productStore.errorMessage!), backgroundColor: Colors.red[700]),
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
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormModal(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Produk Baru'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _productStore.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Cari produk atau SKU...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _productStore.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                if (_productStore.isLoading && _productStore.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_productStore.filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('Produk tidak ditemukan', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _productStore.fetchProducts(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _productStore.filteredProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = _productStore.filteredProducts[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.imageUrl != null
                                ? Image.network(
                                    'http://10.0.2.2:8000${product.imageUrl}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.indigo.shade50,
                                    child: const Icon(Icons.inventory_2, color: Colors.indigo),
                                  ),
                          ),
                          title: Text(
                            product.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('SKU: ${product.sku} | Kategori: ${product.categoryName ?? 'Umum'}',
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                'Jual: Rp ${product.sellPrice.toStringAsFixed(0)} | Stok: ${product.stockQuantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.indigo),
                                onPressed: () => _showFormModal(product: product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(product),
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
          ),
        ],
      ),
    );
  }
}