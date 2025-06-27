import 'package:flutter/material.dart';
import 'package:servis/helpers/database_helper.dart';
import 'package:servis/models/setting.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _noteHeaderController = TextEditingController();
  final _noteFooterController = TextEditingController();

  bool _isLoading = true;
  int? _settingId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settingsData = await DatabaseHelper.instance.queryAllRows('settings');
      if (settingsData.isNotEmpty) {
        final setting = Setting.fromMap(settingsData.first);
        setState(() {
          _businessNameController.text = setting.businessName ?? '';
          _noteHeaderController.text = setting.noteHeader ?? '';
          _noteFooterController.text = setting.noteFooter ?? '';
          _settingId = setting.id;
        });
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

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final setting = Setting(
          id: _settingId,
          businessName: _businessNameController.text,
          noteHeader: _noteHeaderController.text,
          noteFooter: _noteFooterController.text,
          updatedAt: DateTime.now().toIso8601String(),
        );

        if (_settingId == null) {
          await DatabaseHelper.instance.insert('settings', setting.toMap());
        } else {
          await DatabaseHelper.instance.update('settings', setting.toMap());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
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
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _noteHeaderController.dispose();
    _noteFooterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengaturan Umum',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Usaha',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama usaha tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      'Pengaturan Nota',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _noteHeaderController,
                      decoration: const InputDecoration(
                        labelText: 'Header Nota',
                        border: OutlineInputBorder(),
                        hintText: 'Teks yang akan muncul di bagian atas nota',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _noteFooterController,
                      decoration: const InputDecoration(
                        labelText: 'Footer Nota',
                        border: OutlineInputBorder(),
                        hintText: 'Teks yang akan muncul di bagian bawah nota',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32.0),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveSettings,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Simpan Pengaturan',
                                style: TextStyle(fontSize: 16.0),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
