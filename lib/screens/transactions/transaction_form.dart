import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servis/models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;
  final List<Map<String, dynamic>> depositedItems;
  final Function(
    String type,
    String description,
    double amount,
    String category,
    int? depositedItemId,
  ) onSave;

  const TransactionForm({
    super.key,
    this.transaction,
    required this.depositedItems,
    required this.onSave,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  late String _selectedType;
  int? _selectedItemId;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transaction?.type ?? 'income';
    _selectedItemId = widget.transaction?.depositedItemId;
    _descriptionController.text = widget.transaction?.description ?? '';
    _amountController.text = widget.transaction?.amount.toString() ?? '';
    _categoryController.text = widget.transaction?.category ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.transaction == null
                        ? 'Tambah Transaksi'
                        : 'Edit Transaksi',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeRadio(
                      'income',
                      'Pemasukan',
                      Icons.arrow_downward,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypeRadio(
                      'expense',
                      'Pengeluaran',
                      Icons.arrow_upward,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Jumlah harus berupa angka';
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (widget.depositedItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  value: _selectedItemId,
                  decoration: InputDecoration(
                    labelText: 'Barang Servis',
                    prefixIcon: const Icon(Icons.build),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Pilih Barang Servis'),
                    ),
                    ...widget.depositedItems.map((item) {
                      return DropdownMenuItem<int?>(
                        value: item['id'] as int,
                        child: Text(
                          '${item['customer_name']} - ${item['item_name']}',
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedItemId = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.transaction == null ? 'Simpan' : 'Update',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeRadio(
    String type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _selectedType,
        _descriptionController.text,
        double.parse(_amountController.text),
        _categoryController.text,
        _selectedItemId,
      );
      Navigator.pop(context);
    }
  }
} 