import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:servis/helpers/database_helper.dart';
import 'package:servis/screens/customers_screen.dart';
import 'package:servis/screens/deposited_items_screen.dart';
import 'package:servis/screens/purchases_screen.dart';
import 'package:servis/screens/savings_screen.dart';
import 'package:servis/screens/settings_screen.dart';
import 'package:servis/screens/transactions_screen.dart';
import 'package:servis/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Map<String, dynamic>> _waitingItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _loadWaitingItems();
  }

  Future<void> _loadWaitingItems() async {
    try {
      final items = await DatabaseHelper.instance.getWaitingDepositedItems();
      setState(() {
        _waitingItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Aplikasi Manajemen Servis'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadWaitingItems,
              ),
            ],
          ),
          if (_waitingItems.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.pending_actions,
                              color: theme.colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Daftar Tunggu Servis',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _waitingItems.length,
                        itemBuilder: (context, index) {
                          final item = _waitingItems[index];
                          final receivedDate = DateTime.parse(item['received_date']);
                          final formattedDate = DateFormat('dd/MM/yyyy').format(receivedDate);
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              child: Text(
                                item['customer_name'][0].toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              item['item_name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['customer_name']),
                                Text(
                                  'Diterima: $formattedDate',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                'Menunggu',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DepositedItemsScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Lihat Semua Barang Servis'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 2 : 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildListDelegate([
                _buildAnimatedMenuCard(
                  context,
                  'Konsumen',
                  Icons.people,
                  theme.colorScheme.primary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomersScreen()),
                  ),
                  _animation,
                  delay: 0,
                ),
                _buildAnimatedMenuCard(
                  context,
                  'Barang Servis',
                  Icons.devices,
                  theme.colorScheme.secondary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DepositedItemsScreen()),
                  ),
                  _animation,
                  delay: 1,
                ),
                _buildAnimatedMenuCard(
                  context,
                  'Transaksi',
                  Icons.payment,
                  theme.colorScheme.tertiary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                  ),
                  _animation,
                  delay: 2,
                ),
                _buildAnimatedMenuCard(
                  context,
                  'Tabungan',
                  Icons.savings,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavingsScreen()),
                  ),
                  _animation,
                  delay: 3,
                ),
                _buildAnimatedMenuCard(
                  context,
                  'Pembelian',
                  Icons.shopping_cart,
                  Colors.red,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PurchasesScreen()),
                  ),
                  _animation,
                  delay: 4,
                ),
                _buildAnimatedMenuCard(
                  context,
                  'Pengaturan',
                  Icons.settings,
                  Colors.grey,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  _animation,
                  delay: 5,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    Animation<double> animation,
    {required int delay,
  }) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final delayedAnimation = Curves.easeOut.transform(
          (animation.value - (delay * 0.1)).clamp(0.0, 1.0),
        );
        
        return Transform.scale(
          scale: 0.6 + (0.4 * delayedAnimation),
          child: Opacity(
            opacity: delayedAnimation,
            child: Card(
              elevation: 8.0 * delayedAnimation,
              shadowColor: color.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 48.0,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
