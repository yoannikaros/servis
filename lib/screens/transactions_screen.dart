import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:servis/helpers/database_helper.dart';
import 'package:servis/models/transaction.dart';
import 'package:servis/screens/receipt_screen.dart';
import 'package:servis/screens/transactions/transaction_card.dart';
import 'package:servis/screens/transactions/transaction_form.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedType = 'all';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactionsData =
          await DatabaseHelper.instance.queryAllRows('transactions');
      setState(() {
        _transactions = transactionsData
            .map((data) => Transaction.fromMap(data))
            .toList()
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        _filterTransactions();
      });
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        final matchesSearch = transaction.description?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false;
        final matchesType = _selectedType == 'all' ||
            transaction.type == _selectedType;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
                                  ),
            child: const Text('Hapus'),
                                ),
                              ],
                            ),
    );

    if (confirmed == true) {
      try {
        await DatabaseHelper.instance
            .delete('transactions', transaction.id!);
        setState(() {
          _transactions.removeWhere((t) => t.id == transaction.id);
          _filterTransactions();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi berhasil dihapus'),
              backgroundColor: Colors.green,
                                    ),
                                  );
                                }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus transaksi: $e'),
              backgroundColor: Colors.red,
      ),
    );
        }
      }
    }
  }

  Future<void> _showTransactionForm({Transaction? transaction}) async {
    List<Map<String, dynamic>> items = [];
    try {
      items = await DatabaseHelper.instance.getDepositedItemsWithCustomer();
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
      }
      return;
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
        child: TransactionForm(
          transaction: transaction,
          depositedItems: items,
          onSave: (type, description, amount, category, depositedItemId) async {
            try {
              final Map<String, dynamic> row = {
                'type': type,
                'description': description,
                'amount': amount,
                'category': category,
                'deposited_item_id': depositedItemId,
                'transaction_date': DateTime.now().toIso8601String(),
              };

              if (transaction != null) {
                await DatabaseHelper.instance.update(
                  'transactions',
                  {
                    ...row,
                    'id': transaction.id,
                  },
                );
                                  } else {
                await DatabaseHelper.instance.insert('transactions', row);
              }

              await _loadTransactions();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      transaction == null
                          ? 'Transaksi berhasil ditambahkan'
                          : 'Transaksi berhasil diperbarui',
                                        ),
                    backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
              if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Terjadi kesalahan: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('Daftar Transaksi'),
            floating: true,
            snap: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari transaksi...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filterTransactions();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Semua', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Pemasukan', 'income'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Pengeluaran', 'expense'),
                        ],
                      ),
                      ),
                    ],
                  ),
              ),
            ),
          ),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Belum ada transaksi'
                              : 'Tidak ada transaksi yang sesuai',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _filteredTransactions[index];
                        return TransactionCard(
                          transaction: transaction,
                          currencyFormat: _currencyFormat,
                          onEdit: () => _showTransactionForm(
                            transaction: transaction,
                          ),
                          onDelete: () => _deleteTransaction(transaction),
                          onViewReceipt: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReceiptScreen(
                                  transactionId: transaction.id!,
                                  depositedItemId: transaction.depositedItemId,
                ),
              ),
            );
          },
        );
      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionForm(),
        icon: const Icon(Icons.add),
        label: const Text('Transaksi Baru'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = _selectedType == type;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : 'all';
          _filterTransactions();
        });
      },
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
  }
}
