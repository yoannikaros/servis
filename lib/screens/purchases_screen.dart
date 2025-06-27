import 'package:flutter/material.dart';
import 'package:servis/helpers/database_helper.dart';
import 'package:servis/models/purchase.dart';
import 'package:intl/intl.dart';
import 'package:servis/screens/purchases/purchase_card.dart';
import 'package:servis/screens/purchases/purchase_form.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  List<Purchase> _purchases = [];
  List<Purchase> _filteredPurchases = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadPurchases();
    _searchController.addListener(_filterPurchases);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPurchases() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPurchases = _purchases.where((purchase) {
        final matchesQuery = purchase.itemName.toLowerCase().contains(query) ||
            (purchase.category?.toLowerCase().contains(query) ?? false) ||
            (purchase.notes?.toLowerCase().contains(query) ?? false);
        
        final matchesCategory = _selectedCategory == 'all' || 
            purchase.category == _selectedCategory;
        
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  Set<String> get _categories {
    return _purchases
        .where((p) => p.category != null && p.category!.isNotEmpty)
        .map((p) => p.category!)
        .toSet();
  }

  Future<void> _loadPurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final purchasesData = await DatabaseHelper.instance.queryAllRows('purchases');
      setState(() {
        _purchases = purchasesData.map((data) => Purchase.fromMap(data)).toList();
        _filterPurchases();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showPurchaseForm({Purchase? purchase}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PurchaseForm(
        purchase: purchase,
        onSuccess: _loadPurchases,
      ),
    );
  }

  Future<void> _deletePurchase(Purchase purchase) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'Apakah Anda yakin ingin menghapus pembelian "${purchase.itemName}"?',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tindakan ini tidak dapat dibatalkan.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
            ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            child: const Text('Hapus'),
          ),
        ],
        );
      },
    );

    if (confirm == true) {
      try {
        await DatabaseHelper.instance.delete('purchases', purchase.id!);
        if (!mounted) return;
        _loadPurchases();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembelian berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFilterChip(String label, String category) {
    final isSelected = _selectedCategory == category;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : 'all';
            _filterPurchases();
          });
        },
        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
        checkmarkColor: theme.colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pembelian'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari pembelian...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              if (_categories.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', 'all'),
                      ..._categories.map((category) => _buildFilterChip(category, category)),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _loadPurchases,
              child: _filteredPurchases.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: theme.colorScheme.secondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty && _selectedCategory == 'all'
                                ? 'Belum ada data pembelian'
                                : 'Tidak ada pembelian yang sesuai filter',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.secondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredPurchases.length,
                      itemBuilder: (context, index) {
                        final purchase = _filteredPurchases[index];
                        return PurchaseCard(
                          purchase: purchase,
                          onEdit: () => _showPurchaseForm(purchase: purchase),
                          onDelete: () => _deletePurchase(purchase),
                          currencyFormat: _currencyFormat,
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPurchaseForm(),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Tambah Pembelian'),
      ),
    );
  }
}
