import 'package:flutter/material.dart';
import 'package:servis/helpers/database_helper.dart';
import 'package:servis/models/service_log.dart';

class ServiceLogsScreen extends StatefulWidget {
  final int itemId;
  final String itemName;

  const ServiceLogsScreen({
    super.key,
    required this.itemId,
    required this.itemName,
  });

  @override
  State<ServiceLogsScreen> createState() => _ServiceLogsScreenState();
}

class _ServiceLogsScreenState extends State<ServiceLogsScreen> {
  List<ServiceLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logsData =
          await DatabaseHelper.instance.getServiceLogsByItemId(widget.itemId);
      setState(() {
        _logs = logsData.map((data) => ServiceLog.fromMap(data)).toList();
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
        title: Text('Log Servis - ${widget.itemName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('Belum ada log servis'))
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text(log.action),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal: ${log.date}'),
                            if (log.componentUsed != null &&
                                log.componentUsed!.isNotEmpty)
                              Text('Komponen: ${log.componentUsed}'),
                            if (log.componentCost != null)
                              Text(
                                  'Biaya: Rp ${log.componentCost!.toStringAsFixed(0)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showLogForm(log: log);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteLog(log);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLogForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showLogForm({ServiceLog? log}) async {
    final _formKey = GlobalKey<FormState>();
    final _actionController = TextEditingController(text: log?.action);
    final _componentUsedController =
        TextEditingController(text: log?.componentUsed);
    final _componentCostController = TextEditingController(
        text: log?.componentCost?.toString() ?? '');
    final _technicianController =
        TextEditingController(text: log?.technician);
    final _notesController = TextEditingController(text: log?.notes);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log == null ? 'Tambah Log Servis' : 'Edit Log Servis',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _actionController,
                    decoration: const InputDecoration(
                      labelText: 'Tindakan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tindakan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _componentUsedController,
                    decoration: const InputDecoration(
                      labelText: 'Komponen yang Digunakan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _componentCostController,
                    decoration: const InputDecoration(
                      labelText: 'Biaya Komponen',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _technicianController,
                    decoration: const InputDecoration(
                      labelText: 'Teknisi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                            final newLog = ServiceLog(
                              id: log?.id,
                              depositedItemId: widget.itemId,
                              date: log?.date ?? DateTime.now().toIso8601String(),
                              action: _actionController.text,
                              componentUsed: _componentUsedController.text,
                              componentCost: _componentCostController.text.isNotEmpty
                                  ? double.parse(_componentCostController.text)
                                  : null,
                              technician: _technicianController.text,
                              notes: _notesController.text,
                            );

                            try {
                              if (log == null) {
                                // Tambah log baru
                                await DatabaseHelper.instance
                                    .insert('service_logs', newLog.toMap());
                              } else {
                                // Update log
                                await DatabaseHelper.instance
                                    .update('service_logs', newLog.toMap());
                              }
                              if (!mounted) return;
                              Navigator.pop(context);
                              _loadLogs();
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
                        child: Text(log == null ? 'Simpan' : 'Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteLog(ServiceLog log) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Hapus log servis "${log.action}"?'),
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
        await DatabaseHelper.instance.delete('service_logs', log.id!);
        _loadLogs();
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
