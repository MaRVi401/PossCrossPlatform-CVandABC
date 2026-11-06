// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../app/di/injection.dart';
import '../../../../shared/widgets/main_drawer.dart';
import '../../data/models/category_model.dart';
import '../stores/category_store.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryStore _categoryStore = sl<CategoryStore>();
  final TextEditingController _searchController = TextEditingController();

  static const Color _primaryColor = Color(0xFF1E1B4B);
  static const Color _backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade700 : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==========================================================
  // LOAD CATEGORY
  // ==========================================================

  Future<void> _loadCategories() async {
    try {
      await _categoryStore.fetchCategories();
    } catch (e) {
      _showMessage(
        'Gagal memuat kategori: $e',
        isError: true,
      );
    }
  }

  // ==========================================================
  // ADD / EDIT CATEGORY
  // ==========================================================

  Future<void> _showFormModal({
    CategoryModel? category,
  }) async {
    final bool isEdit = category != null;

    final nameController = TextEditingController(
      text: category?.categoryName ?? '',
    );

    final descController = TextEditingController(
      text: category?.description ?? '',
    );

    final formKey = GlobalKey<FormState>();

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isEdit
                                ? Icons.edit_outlined
                                : Icons.add_circle_outline,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEdit ? 'Edit Kategori' : 'Kategori Baru',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(modalContext).pop();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama kategori wajib diisi';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Nama Kategori',
                        hintText: 'Misal: Makanan, Minuman, Elektronik',
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: descController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      maxLength: 255,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi (Opsional)',
                        hintText: 'Masukkan deskripsi kategori',
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Observer(
                      builder: (_) {
                        final isLoading = _categoryStore.isLoading;

                        return SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _primaryColor.withValues(alpha: 0.5),
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

                                    final name =
                                        nameController.text.trim();

                                    final description =
                                        descController.text.trim();

                                    bool success = false;

                                    try {
                                      if (isEdit) {
                                        success = await _categoryStore
                                            .updateCategory(
                                          category.categoryId,
                                          name,
                                          description,
                                        );
                                      } else {
                                        success = await _categoryStore
                                            .addCategory(
                                          name,
                                          description,
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        _showMessage(
                                          'Terjadi kesalahan: $e',
                                          isError: true,
                                        );
                                      }
                                      return;
                                    }

                                    if (!mounted ||
                                        !modalContext.mounted) {
                                      return;
                                    }

                                    if (success) {
                                      Navigator.of(modalContext).pop();

                                      await _loadCategories();

                                      if (!mounted) return;

                                      _showMessage(
                                        isEdit
                                            ? 'Kategori berhasil diperbarui!'
                                            : 'Kategori berhasil ditambahkan!',
                                      );
                                    } else {
                                      _showMessage(
                                        _categoryStore.errorMessage ??
                                            'Gagal menyimpan kategori',
                                        isError: true,
                                      );
                                    }
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isEdit
                                        ? 'Simpan Perubahan'
                                        : 'Tambah Kategori',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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
    } finally {
      nameController.dispose();
      descController.dispose();
    }
  }

  // ==========================================================
  // DELETE CATEGORY
  // ==========================================================

  Future<void> _confirmDelete(CategoryModel category) async {
    bool isProcessing = false;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
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
                  Expanded(
                    child: Text(
                      'Hapus Kategori',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                'Apakah Anda yakin ingin menghapus kategori '
                '"${category.categoryName}"?',
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isProcessing
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(true);
                        },
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      final success = await _categoryStore.deleteCategory(
        category.categoryId,
      );

      if (!mounted) return;

      if (success) {
        await _loadCategories();

        if (!mounted) return;

        _showMessage('Kategori berhasil dihapus!');
      } else {
        _showMessage(
          _categoryStore.errorMessage ?? 'Gagal menghapus kategori',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage(
        'Gagal menghapus kategori: $e',
        isError: true,
      );
    }
  }

  // ==========================================================
  // CATEGORY CARD
  // ==========================================================

  Widget _buildCategoryCard(CategoryModel category) {
    final name = category.categoryName.trim();

    final initial = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : '?';

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFEEF2FF),
          child: Text(
            initial,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: _primaryColor,
            ),
          ),
        ),
        title: Text(
          category.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.description?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 5),
              Text(
                category.description!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${category.productsCount} Produk',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Edit kategori',
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.edit_outlined,
                color: _primaryColor,
              ),
              onPressed: () {
                _showFormModal(category: category);
              },
            ),
            IconButton(
              tooltip: 'Hapus kategori',
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              onPressed: () {
                _confirmDelete(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Kategori tidak ditemukan',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Coba ubah kata kunci pencarian',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CATEGORY LIST
  // ==========================================================

  Widget _buildCategoryList(List<CategoryModel> categories) {
    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          110,
        ),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _buildCategoryCard(categories[index]);
        },
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Manajemen Kategori',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: _loadCategories,
          ),
        ],
      ),

      drawer: const MainDrawer(
        currentRoute: 'category',
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showFormModal();
        },
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Kategori Baru',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _categoryStore.setSearchQuery(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Cari kategori...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _categoryStore.setSearchQuery('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
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
                final categories =
                    _categoryStore.filteredCategories;

                if (_categoryStore.isLoading &&
                    categories.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _primaryColor,
                    ),
                  );
                }

                if (categories.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildCategoryList(categories);
              },
            ),
          ),
        ],
      ),
    );
  }
}