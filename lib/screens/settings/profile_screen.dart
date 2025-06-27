import 'package:flutter/material.dart';
import 'package:servis/helpers/database_helper.dart';
import 'package:servis/screens/login_screen.dart';
import 'change_username_screen.dart';
import 'change_password_screen.dart';
import 'delete_account_screen.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';
import 'contact_us_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  Future<Map<String, dynamic>> _loadUserData() async {
    // Annoying to get username, so just assume admin for now as it's the only user
    final user = await DatabaseHelper.instance.getUserByUsername('admin');
    if (user != null) {
      return {
        'id': user['id'],
        'username': user['username'],
        'avatar': user['username'].substring(0, 1).toUpperCase(),
      };
    }
    return {'id': -1, 'username': 'Error', 'avatar': 'E'};
  }

  void _logout() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Pengaturan'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!['id'] == -1) {
            return const Center(child: Text('Gagal memuat data pengguna'));
          }

          final userData = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _userFuture = _loadUserData();
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileHeader(userData),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Akun',
                  children: [
                    _buildSettingItem(
                      icon: Icons.person_outline,
                      title: 'Ubah Username',
                      subtitle: userData['username'],
                      onTap: () async {
                        final newUsername = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeUsernameScreen(
                              currentUsername: userData['username'],
                              userId: userData['id'],
                            ),
                          ),
                        );
                        if (newUsername != null) {
                          setState(() {
                             _userFuture = _loadUserData();
                          });
                        }
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.lock_outline,
                      title: 'Ubah Password',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen(userId: userData['id']))),
                    ),
                    _buildSettingItem(
                      icon: Icons.delete_forever_outlined,
                      title: 'Hapus Akun',
                      color: Theme.of(context).colorScheme.error,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DeleteAccountScreen(userId: userData['id'], username: userData['username']))),
                    ),
                  ],
                ),
                _buildSection(
                  title: 'Dukungan & Legal',
                  children: [
                     _buildSettingItem(
                      icon: Icons.description_outlined,
                      title: 'Syarat & Ketentuan',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsOfServiceScreen())),
                    ),
                    _buildSettingItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Kebijakan Privasi',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
                    ),
                    _buildSettingItem(
                      icon: Icons.contact_support_outlined,
                      title: 'Kontak Kami',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          child: Text(userData['avatar'], style: const TextStyle(fontSize: 32)),
        ),
        const SizedBox(height: 12),
        Text(
          userData['username'],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 