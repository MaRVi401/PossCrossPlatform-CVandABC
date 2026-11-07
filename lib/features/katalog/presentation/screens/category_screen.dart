
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
  final TextEditingController _searchController =
      TextEditingController();

  static const Color _primaryColor = Color(0xFF1E1B4B);
  static const Color _backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCategories();
      }
    });
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
  // LOAD CATEGORIES
  // ==========================================================

  Future<void> _loadCategories() async {
    if (!mounted) return;

    try {
      await _categoryStore.fetchCategories();
    } catch (e) {
      if (mounted) {
        _showMessage(
          'Gagal memuat kategori: $e',
          isError: true,
        );
      }
    }
  }

  // ==========================================================
  // ADD / EDIT FORM
  // ==========================================================

  Future<void> _showFormModal({
    CategoryModel? category,
  }) async {
    final isEdit = category != null;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _CategoryFormSheet(
          category: category,
          categoryStore: _categoryStore,
          primaryColor: _primaryColor,
        );
      },
    );

    // Modal sudah selesai ditutup sebelum melakukan refresh.
    if (result == true && mounted) {
      await _loadCategories();

      if (!mounted) return;

      _showMessage(
        isEdit
            ? 'Kategori berhasil diperbarui!'
            : 'Kategori berhasil ditambahkan!',
      );
    }
  }

  // ==========================================================
  // DELETE CATEGORY
  // ==========================================================

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
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
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Hapus'),
            ),
          ],
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
          _categoryStore.errorMessage ??
              'Gagal menghapus kategori',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          'Gagal menghapus kategori: $e',
          isError: true,
        );
      }
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
        separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
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
            child: Observer(
              builder: (_) {
                final query = _categoryStore.searchQuery;

                return TextField(
                  controller: _searchController,
                  onChanged: _categoryStore.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Cari kategori...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _categoryStore.setSearchQuery('');
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
                );
              },
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                final categories =
                    _categoryStore.filteredCategories;

                final isLoading = _categoryStore.isLoading;

                if (isLoading && categories.isEmpty) {
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

// ============================================================
// CATEGORY FORM - SEPARATE STATEFUL WIDGET
// ============================================================

class _CategoryFormSheet extends StatefulWidget {
  final CategoryModel? category;
  final CategoryStore categoryStore;
  final Color primaryColor;

  const _CategoryFormSheet({
    this.category,
    required this.categoryStore,
    required this.primaryColor,
  });

  @override
  State<_CategoryFormSheet> createState() =>
      _CategoryFormSheetState();
}

class _CategoryFormSheetState
    extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool _submitting = false;

  bool get isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.category?.categoryName ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SAVE CATEGORY
  // ==========================================================

  Future<void> _saveCategory() async {
    if (_submitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    final name = _nameController.text.trim();

    final description = _descriptionController.text.trim();

    try {
      final bool success;

      if (isEdit) {
        success = await widget.categoryStore.updateCategory(
          widget.category!.categoryId,
          name,
          description.isEmpty ? null : description,
        );
      } else {
        success = await widget.categoryStore.addCategory(
          name,
          description.isEmpty ? null : description,
        );
      }

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _submitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.categoryStore.errorMessage ??
                  'Gagal menyimpan kategori',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================================
  // BUILD FORM
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Padding(
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
                // HEADER
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
                        color: widget.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit
                            ? 'Edit Kategori'
                            : 'Kategori Baru',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: widget.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _submitting
                          ? null
                          : () {
                              Navigator.of(context).pop(false);
                            },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // CATEGORY NAME
                TextFormField(
                  controller: _nameController,
                  enabled: !_submitting,
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
                    hintText:
                        'Misal: Makanan, Minuman, Elektronik',
                    prefixIcon:
                        const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // DESCRIPTION
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_submitting,
                  textCapitalization:
                      TextCapitalization.sentences,
                  maxLines: 3,
                  maxLength: 255,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
                    hintText: 'Masukkan deskripsi kategori',
                    prefixIcon:
                        const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SAVE BUTTON
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          widget.primaryColor.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        _submitting ? null : _saveCategory,
                    child: _submitting
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
