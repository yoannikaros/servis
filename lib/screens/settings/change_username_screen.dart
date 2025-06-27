import 'package:flutter/material.dart';
import 'package:servis/helpers/database_helper.dart';

class ChangeUsernameScreen extends StatefulWidget {
  final String currentUsername;
  final int userId;

  const ChangeUsernameScreen({
    super.key,
    required this.currentUsername,
    required this.userId,
  });

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.currentUsername;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username == widget.currentUsername) {
      setState(() {
        _usernameError = null;
      });
      return;
    }

    try {
      final isAvailable = await DatabaseHelper.instance.isUsernameAvailable(
        username,
        excludeUserId: widget.userId,
      );
      setState(() {
        _usernameError = isAvailable ? null : 'Username sudah digunakan';
      });
    } catch (e) {
      setState(() {
        _usernameError = 'Gagal memeriksa username';
      });
    }
  }

  Future<void> _updateUsername() async {
    if (!_formKey.currentState!.validate() || _usernameError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verifikasi password
      final userData = await DatabaseHelper.instance.getUserByUsername(widget.currentUsername);
      if (userData == null || userData['password'] != _currentPasswordController.text) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password salah'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Update username
      final success = await DatabaseHelper.instance.updateUsername(
        widget.userId,
        _usernameController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username berhasil diubah'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, _usernameController.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username sudah digunakan'),
            backgroundColor: Colors.red,
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Username'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Username baru harus unik dan akan digunakan untuk login.',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username Baru',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _usernameError,
                  ),
                  onChanged: (value) {
                    if (value.length > 2) {
                      _checkUsernameAvailability(value);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    if (value.length < 3) {
                      return 'Username minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password Saat Ini',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateUsername,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 16),
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