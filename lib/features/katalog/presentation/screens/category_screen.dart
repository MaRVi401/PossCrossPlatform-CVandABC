// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../app/di/injection.dart';
import '../stores/category_store.dart';
import '../../data/models/category_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _categoryStore = sl<CategoryStore>();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoryStore.fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFormModal({CategoryModel? category}) {
    final isEdit = category != null;
    final nameController =
        TextEditingController(text: category?.categoryName ?? '');
    final descController =
        TextEditingController(text: category?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      isEdit ? Icons.edit_outlined : Icons.add_circle_outline,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEdit ? 'Edit Kategori' : 'Tambah Kategori Baru',
                      style:
                          Theme.of(modalContext).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade900,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama kategori wajib diisi'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Misal: Makanan, Minuman, Elektronik',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Observer(
                  builder: (_) {
                    return SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        // Di dalam _showFormModal (bagian tombol Simpan/Tambah)
                        onPressed: _categoryStore.isLoading
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;

                                final name = nameController.text.trim();
                                final desc = descController.text.trim();

                                final success = isEdit
                                    ? await _categoryStore.updateCategory(
                                        category.categoryId, name, desc)
                                    : await _categoryStore.addCategory(
                                        name, desc);

                                // Pastikan modalContext masih aktif/mounted sebelum dipakai
                                if (!modalContext.mounted) return;

                                if (success) {
                                  Navigator.pop(modalContext);
                                  ScaffoldMessenger.of(modalContext)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEdit
                                            ? 'Kategori berhasil diperbarui!'
                                            : 'Kategori berhasil ditambahkan!',
                                      ),
                                      backgroundColor: Colors.green[700],
                                    ),
                                  );
                                } else if (_categoryStore.errorMessage !=
                                    null) {
                                  ScaffoldMessenger.of(modalContext)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(_categoryStore.errorMessage!),
                                      backgroundColor: Colors.red[700],
                                    ),
                                  );
                                }
                              },
                        child: _categoryStore.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEdit
                                ? 'Simpan Perubahan'
                                : 'Tambah Kategori'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(CategoryModel category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Kategori'),
          ],
        ),
        content: Text(
            'Apakah Anda yakin ingin menghapus kategori "${category.categoryName}"?'),
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
              final success =
                  await _categoryStore.deleteCategory(category.categoryId);

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kategori berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (_categoryStore.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_categoryStore.errorMessage!),
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
      appBar: AppBar(
        title: const Text('Manajemen Kategori'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormModal(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Kategori Baru'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _categoryStore.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Cari kategori...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _categoryStore.setSearchQuery('');
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

          // Categories List View
          Expanded(
            child: Observer(
              builder: (_) {
                if (_categoryStore.isLoading &&
                    _categoryStore.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_categoryStore.filteredCategories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Kategori tidak ditemukan',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _categoryStore.fetchCategories(),
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _categoryStore.filteredCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final category = _categoryStore.filteredCategories[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade50,
                            child: Text(
                              category.categoryName
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                          ),
                          title: Text(
                            category.categoryName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (category.description?.isNotEmpty == true)
                                Text(
                                  category.description!,
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13),
                                ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${category.productsCount} Produk',
                                  style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Colors.indigo),
                                onPressed: () =>
                                    _showFormModal(category: category),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () => _confirmDelete(category),
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
