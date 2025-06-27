import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:servis/helpers/database_helper.dart';
import 'package:servis/models/deposited_item.dart';
import 'package:servis/models/customer.dart';
import 'package:servis/models/setting.dart';
import 'package:servis/models/transaction.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptScreen extends StatefulWidget {
  final int transactionId;
  final int? depositedItemId;

  const ReceiptScreen({
    super.key,
    required this.transactionId,
    this.depositedItemId,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool _isLoading = true;
  Transaction? _transaction;
  DepositedItem? _item;
  Customer? _customer;
  Setting? _setting;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil data transaksi
      final transactionData = await DatabaseHelper.instance
          .queryById('transactions', widget.transactionId);
      if (transactionData != null) {
        _transaction = Transaction.fromMap(transactionData);
      }

      // Ambil data barang servis jika ada
      if (widget.depositedItemId != null) {
        final itemData = await DatabaseHelper.instance
            .queryById('deposited_items', widget.depositedItemId!);
        if (itemData != null) {
          _item = DepositedItem.fromMap(itemData);

          // Ambil data konsumen
          if (_item != null) {
            final customerData = await DatabaseHelper.instance
                .queryById('customers', _item!.customerId);
            if (customerData != null) {
              _customer = Customer.fromMap(customerData);
            }
          }
        }
      }

      // Ambil pengaturan
      final settingsData = await DatabaseHelper.instance.queryAllRows('settings');
      if (settingsData.isNotEmpty) {
        _setting = Setting.fromMap(settingsData.first);
      }
    } catch (e) {
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

  Future<void> _shareReceipt() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/struk_${DateTime.now().millisecondsSinceEpoch}.png';
      
      final imageFile = await _screenshotController.captureAndSave(
        directory.path,
        fileName: 'struk_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (imageFile != null) {
        await Share.shareXFiles(
          [XFile(imageFile)],
          text: 'Struk Transaksi - ${_setting?.businessName ?? 'Toko Servis'}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membagikan struk: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isLoading ? null : _shareReceipt,
            tooltip: 'Bagikan Struk',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transaction == null
              ? const Center(child: Text('Data transaksi tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      _setting?.businessName ?? 'Toko Servis',
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    const Text(
                                      'STRUK TRANSAKSI',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    const Divider(thickness: 2.0),
                                  ],
                                ),
                              ),
                              
                              // Tanggal dan No. Transaksi
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('No. Transaksi:'),
                                  Text('#${_transaction!.id}'),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tanggal:'),
                                  Text(_formatDate(_transaction!.transactionDate)),
                                ],
                              ),
                              
                              // Data Konsumen (jika ada)
                              if (_customer != null) ...[
                                const SizedBox(height: 16.0),
                                const Divider(),
                                const Text(
                                  'DATA KONSUMEN',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Nama:'),
                                    Text(_customer!.name),
                                  ],
                                ),
                                if (_customer!.phone != null && _customer!.phone!.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Telepon:'),
                                      Text(_customer!.phone!),
                                    ],
                                  ),
                              ],
                              
                              // Data Barang (jika ada)
                              if (_item != null) ...[
                                const SizedBox(height: 16.0),
                                const Divider(),
                                const Text(
                                  'DETAIL BARANG',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Barang:'),
                                    Text(_item!.itemName),
                                  ],
                                ),
                                if (_item!.brand != null && _item!.brand!.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Merek:'),
                                      Text(_item!.brand!),
                                    ],
                                  ),
                                if (_item!.model != null && _item!.model!.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Model:'),
                                      Text(_item!.model!),
                                    ],
                                  ),
                                if (_item!.serialNumber != null && _item!.serialNumber!.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('No. Seri:'),
                                      Text(_item!.serialNumber!),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Status:'),
                                    _buildStatusBadge(_item!.status),
                                  ],
                                ),
                              ],
                              
                              // Detail Transaksi
                              const SizedBox(height: 16.0),
                              const Divider(),
                              const Text(
                                'DETAIL TRANSAKSI',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Jenis:'),
                                  Text(_transaction!.type == 'income' ? 'Pemasukan' : 'Pengeluaran'),
                                ],
                              ),
                              if (_transaction!.description != null && _transaction!.description!.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Deskripsi:'),
                                    Text(_transaction!.description!),
                                  ],
                                ),
                              if (_transaction!.category != null && _transaction!.category!.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Kategori:'),
                                    Text(_transaction!.category!),
                                  ],
                                ),
                              const SizedBox(height: 16.0),
                              const Divider(thickness: 1.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'TOTAL',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Rp ${_transaction!.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Divider(thickness: 1.0),
                              
                              // Footer
                              const SizedBox(height: 16.0),
                              if (_setting?.noteFooter != null && _setting!.noteFooter!.isNotEmpty)
                                Center(
                                  child: Text(
                                    _setting!.noteFooter!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8.0),
                              const Center(
                                child: Text(
                                  'Terima Kasih',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        onPressed: _shareReceipt,
                        icon: const Icon(Icons.share),
                        label: const Text('Bagikan Struk'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'waiting':
        color = Colors.orange;
        text = 'Menunggu';
        break;
      case 'in_progress':
        color = Colors.blue;
        text = 'Dalam Proses';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Selesai';
        break;
      case 'picked_up':
        color = Colors.grey;
        text = 'Diambil';
        break;
      default:
        color = Colors.black;
        text = 'Tidak Diketahui';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.0,
        ),
      ),
    );
  }
}
