import 'package:flutter/material.dart';
import 'package:servis/helpers/database_helper.dart';
import 'package:servis/models/purchase.dart';

class PurchaseForm extends StatefulWidget {
  final Purchase? purchase;
  final VoidCallback onSuccess;

  const PurchaseForm({
    super.key,
    this.purchase,
    required this.onSuccess,
  });

  @override
  State<PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends State<PurchaseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemNameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _notesController;
  late final TextEditingController _totalPriceController;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(text: widget.purchase?.itemName);
    _categoryController = TextEditingController(text: widget.purchase?.category);
    _quantityController = TextEditingController(text: widget.purchase?.quantity?.toString() ?? '');
    _unitPriceController = TextEditingController(text: widget.purchase?.unitPrice?.toString() ?? '');
    _notesController = TextEditingController(text: widget.purchase?.notes);
    _totalPriceController = TextEditingController(text: widget.purchase?.totalPrice?.toString() ?? '');
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _notesController.dispose();
    _totalPriceController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final total = quantity * unitPrice;
    _totalPriceController.text = total.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                    widget.purchase == null ? 'Tambah Pembelian' : 'Edit Pembelian',
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
              TextFormField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Barang',
                  prefixIcon: const Icon(Icons.shopping_bag),
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
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: const Icon(Icons.category),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Jumlah',
                        prefixIcon: const Icon(Icons.shopping_basket),
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
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _calculateTotal();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitPriceController,
                      decoration: InputDecoration(
                        labelText: 'Harga Satuan',
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: 'Rp ',
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
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _calculateTotal();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalPriceController,
                decoration: InputDecoration(
                  labelText: 'Total Harga',
                  prefixIcon: const Icon(Icons.monetization_on),
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.primary.withOpacity(0.05),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Total harga tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Total harga harus berupa angka';
                  }
                  return null;
                },
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
                      final newPurchase = Purchase(
                        id: widget.purchase?.id,
                        itemName: _itemNameController.text,
                        category: _categoryController.text,
                        quantity: double.tryParse(_quantityController.text),
                        unitPrice: double.tryParse(_unitPriceController.text),
                        totalPrice: double.parse(_totalPriceController.text),
                        notes: _notesController.text,
                        purchaseDate: widget.purchase?.purchaseDate ?? DateTime.now().toIso8601String(),
                      );

                      try {
                        if (widget.purchase == null) {
                          await DatabaseHelper.instance
                              .insert('purchases', newPurchase.toMap());
                        } else {
                          await DatabaseHelper.instance
                              .update('purchases', newPurchase.toMap());
                        }
                        if (!mounted) return;
                        Navigator.pop(context);
                        widget.onSuccess();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.purchase == null
                                  ? 'Pembelian berhasil ditambahkan'
                                  : 'Pembelian berhasil diperbarui',
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
                    widget.purchase == null ? 'Simpan' : 'Perbarui',
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
  }
} 