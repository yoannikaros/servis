import 'package:flutter/material.dart';
import 'package:servis/helpers/database_helper.dart';
import 'package:servis/models/deposited_item.dart';
import 'package:servis/models/customer.dart';
import 'package:servis/screens/service_logs_screen.dart';

class DepositedItemsScreen extends StatefulWidget {
  const DepositedItemsScreen({super.key});

  @override
  State<DepositedItemsScreen> createState() => _DepositedItemsScreenState();
}

class _DepositedItemsScreenState extends State<DepositedItemsScreen> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'all';
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        final matchesQuery = item['item_name'].toString().toLowerCase().contains(query) ||
            item['customer_name'].toString().toLowerCase().contains(query) ||
            item['brand'].toString().toLowerCase().contains(query) ||
            item['model'].toString().toLowerCase().contains(query);
        
        final matchesStatus = _selectedStatusFilter == 'all' || 
            item['status'] == _selectedStatusFilter;
        
        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final itemsData = await DatabaseHelper.instance.getDepositedItemsWithCustomer();
      setState(() {
        _items = itemsData;
        _filterItems();
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

  String _getStatusText(String status) {
    switch (status) {
      case 'waiting':
        return 'Menunggu';
      case 'in_progress':
        return 'Dalam Proses';
      case 'completed':
        return 'Selesai';
      case 'picked_up':
        return 'Diambil';
      default:
        return 'Tidak Diketahui';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'waiting':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'picked_up':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'waiting':
        return Icons.watch_later;
      case 'in_progress':
        return Icons.build;
      case 'completed':
        return Icons.check_circle;
      case 'picked_up':
        return Icons.inventory;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang Servis'),
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
                    hintText: 'Cari barang servis...',
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _buildFilterChip('Semua', 'all'),
                    _buildFilterChip('Menunggu', 'waiting'),
                    _buildFilterChip('Dalam Proses', 'in_progress'),
                    _buildFilterChip('Selesai', 'completed'),
                    _buildFilterChip('Diambil', 'picked_up'),
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
              onRefresh: _loadItems,
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: theme.colorScheme.secondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty && _selectedStatusFilter == 'all'
                                ? 'Belum ada data barang servis'
                                : 'Tidak ada barang servis yang sesuai filter',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.secondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceLogsScreen(
                                    itemId: item['id'],
                                    itemName: item['item_name'],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(item['status']).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _getStatusIcon(item['status']),
                                          color: _getStatusColor(item['status']),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['item_name'],
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item['brand']} ${item['model']}',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.colorScheme.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showItemForm(item: DepositedItem.fromMap(item));
                                          } else if (value == 'delete') {
                                            _deleteItem(DepositedItem.fromMap(item));
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Hapus', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: theme.colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['customer_name'],
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: theme.colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['received_date'],
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  if (item['complaint'] != null && item['complaint'].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            size: 16,
                                            color: theme.colorScheme.error,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              item['complaint'],
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.colorScheme.error,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Barang'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _selectedStatusFilter == status;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedStatusFilter = selected ? status : 'all';
            _filterItems();
          });
        },
        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
        checkmarkColor: theme.colorScheme.primary,
      ),
    );
  }

  Future<void> _showItemForm({DepositedItem? item}) async {
    final _formKey = GlobalKey<FormState>();
    final _itemNameController = TextEditingController(text: item?.itemName);
    final _brandController = TextEditingController(text: item?.brand);
    final _modelController = TextEditingController(text: item?.model);
    final _serialNumberController = TextEditingController(text: item?.serialNumber);
    final _complaintController = TextEditingController(text: item?.complaint);
    final _technicianController = TextEditingController(text: item?.technician);
    final _notesController = TextEditingController(text: item?.notes);

    String _selectedStatus = item?.status ?? 'waiting';
    int? _selectedCustomerId = item?.customerId;
    List<Customer> _customers = [];

    try {
      final customersData = await DatabaseHelper.instance.queryAllRows('customers');
      _customers = customersData.map((data) => Customer.fromMap(data)).toList();
      if (_customers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada konsumen. Silakan tambahkan konsumen terlebih dahulu.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedCustomerId == null && _customers.isNotEmpty) {
        _selectedCustomerId = _customers.first.id;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item == null ? 'Tambah Barang Servis' : 'Edit Barang Servis',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Konsumen',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                        ),
                        value: _selectedCustomerId,
                        items: _customers.map((customer) {
                          return DropdownMenuItem<int>(
                            value: customer.id,
                            child: Text(customer.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCustomerId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _itemNameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Barang',
                          prefixIcon: const Icon(Icons.devices),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama barang tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _brandController,
                              decoration: InputDecoration(
                                labelText: 'Merek',
                                prefixIcon: const Icon(Icons.branding_watermark),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              decoration: InputDecoration(
                                labelText: 'Model',
                                prefixIcon: const Icon(Icons.phone_android),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _serialNumberController,
                        decoration: InputDecoration(
                          labelText: 'Nomor Seri',
                          prefixIcon: const Icon(Icons.qr_code),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _complaintController,
                        decoration: InputDecoration(
                          labelText: 'Keluhan',
                          prefixIcon: const Icon(Icons.warning_amber_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(
                            _getStatusIcon(_selectedStatus),
                            color: _getStatusColor(_selectedStatus),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                        ),
                        value: _selectedStatus,
                        items: [
                          DropdownMenuItem(
                            value: 'waiting',
                            child: Text(_getStatusText('waiting')),
                          ),
                          DropdownMenuItem(
                            value: 'in_progress',
                            child: Text(_getStatusText('in_progress')),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text(_getStatusText('completed')),
                          ),
                          DropdownMenuItem(
                            value: 'picked_up',
                            child: Text(_getStatusText('picked_up')),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _technicianController,
                        decoration: InputDecoration(
                          labelText: 'Teknisi',
                          prefixIcon: const Icon(Icons.engineering),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Catatan',
                          prefixIcon: const Icon(Icons.note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final newItem = DepositedItem(
                                id: item?.id,
                                customerId: _selectedCustomerId!,
                                itemName: _itemNameController.text,
                                brand: _brandController.text,
                                model: _modelController.text,
                                serialNumber: _serialNumberController.text,
                                complaint: _complaintController.text,
                                status: _selectedStatus,
                                technician: _technicianController.text,
                                notes: _notesController.text,
                                receivedDate: item?.receivedDate ?? DateTime.now().toIso8601String(),
                              );

                              try {
                                if (item == null) {
                                  await DatabaseHelper.instance
                                      .insert('deposited_items', newItem.toMap());
                                } else {
                                  await DatabaseHelper.instance
                                      .update('deposited_items', newItem.toMap());
                                }
                                if (!mounted) return;
                                Navigator.pop(context);
                                _loadItems();
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      item == null
                                          ? 'Barang servis berhasil ditambahkan'
                                          : 'Barang servis berhasil diperbarui',
                                    ),
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
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            item == null ? 'Simpan' : 'Perbarui',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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

  Future<void> _deleteItem(DepositedItem item) async {
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
                'Apakah Anda yakin ingin menghapus barang "${item.itemName}"?',
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
        await DatabaseHelper.instance.delete('deposited_items', item.id!);
        _loadItems();
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
}
