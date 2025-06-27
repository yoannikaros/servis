import 'package:flutter/material.dart';
import 'package:servis/helpers/database_helper.dart';
import 'package:servis/models/saving.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  List<Saving> _savings = [];
  bool _isLoading = true;
  double _totalSavings = 0;

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  Future<void> _loadSavings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final savingsData = await DatabaseHelper.instance.queryAllRows('savings');
      final savings =
          savingsData.map((data) => Saving.fromMap(data)).toList();

      double total = 0;
      for (var saving in savings) {
        if (saving.type == 'deposit') {
          total += saving.amount;
        } else {
          total -= saving.amount;
        }
      }

      setState(() {
        _savings = savings;
        _totalSavings = total;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabungan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Tabungan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Rp ${_totalSavings.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _savings.isEmpty
                      ? const Center(child: Text('Belum ada data tabungan'))
                      : ListView.builder(
                          itemCount: _savings.length,
                          itemBuilder: (context, index) {
                            final saving = _savings[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: ListTile(
                                leading: Icon(
                                  saving.type == 'deposit'
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: saving.type == 'deposit'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(
                                  saving.description ?? 'Tabungan',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Tanggal: ${saving.date}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Rp ${saving.amount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: saving.type == 'deposit'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        Text(
                                          saving.type == 'deposit'
                                              ? 'Setoran'
                                              : 'Penarikan',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: saving.type == 'deposit'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteSaving(saving);
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _showSavingForm(saving: saving);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSavingForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showSavingForm({Saving? saving}) async {
    final _formKey = GlobalKey<FormState>();
    final _descriptionController =
        TextEditingController(text: saving?.description);
    final _amountController =
        TextEditingController(text: saving?.amount.toString() ?? '');

    String _selectedType = saving?.type ?? 'deposit';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saving == null ? 'Tambah Tabungan' : 'Edit Tabungan',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Setoran'),
                            value: 'deposit',
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Penarikan'),
                            value: 'withdrawal',
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
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
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 16.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final newSaving = Saving(
                                id: saving?.id,
                                type: _selectedType,
                                amount: double.parse(_amountController.text),
                                description: _descriptionController.text,
                                date: saving?.date ??
                                    DateTime.now().toIso8601String(),
                              );

                              try {
                                if (saving == null) {
                                  // Tambah tabungan baru
                                  await DatabaseHelper.instance
                                      .insert('savings', newSaving.toMap());
                                } else {
                                  // Update tabungan
                                  await DatabaseHelper.instance
                                      .update('savings', newSaving.toMap());
                                }
                                if (!mounted) return;
                                Navigator.pop(context);
                                _loadSavings();
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
                          child: Text(saving == null ? 'Simpan' : 'Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteSaving(Saving saving) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Hapus data tabungan "${saving.description ?? 'Tabungan'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper.instance.delete('savings', saving.id!);
        _loadSavings();
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
