// setting.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'providers/transaksi_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      _isNotificationEnabled = prefs.getBool('is_notification_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    await prefs.setBool('is_notification_enabled', _isNotificationEnabled);
  }

  Future<void> _logout(BuildContext context) async {
    final transaksiProvider =
        Provider.of<TransaksiProvider>(context, listen: false);

    // Hapus status login
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');

    // Reset transaksi
    await transaksiProvider.resetTransaksi();

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSection(
              title: 'Tampilan',
              icon: Icons.palette,
              children: [
                _buildSettingTile(
                  icon: Icons.dark_mode,
                  title: 'Mode Gelap',
                  subtitle: 'Ubah tema aplikasi',
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                        _saveSettings();
                      });
                    },
                    activeColor: Colors.blue[900],
                  ),
                ),
                _buildSettingTile(
                  icon: Icons.notifications,
                  title: 'Notifikasi',
                  subtitle: 'Aktifkan notifikasi',
                  trailing: Switch(
                    value: _isNotificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isNotificationEnabled = value;
                        _saveSettings();
                      });
                    },
                    activeColor: Colors.blue[900],
                  ),
                ),
              ],
            ),
            _buildSection(
              title: 'Akun',
              icon: Icons.account_circle,
              children: [
                _buildSettingTile(
                  icon: Icons.person,
                  title: 'Ubah Username',
                  subtitle: 'Ganti username Anda',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Ubah Username'),
                        content: TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username Baru',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildSettingTile(
                  icon: Icons.lock,
                  title: 'Ubah Password',
                  subtitle: 'Ganti password Anda',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Ubah Password'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password Lama',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _newPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password Baru',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildSection(
              title: 'Bantuan',
              icon: Icons.help,
              children: [
                _buildSettingTile(
                  icon: Icons.chat,
                  title: 'Pusat Bantuan',
                  subtitle: 'Chat dengan customer service',
                  onTap: () {
                    // Implementasi chat
                  },
                ),
                _buildSettingTile(
                  icon: Icons.phone,
                  title: 'Kontak Kami',
                  subtitle: 'Hubungi kami',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Kontak Kami'),
                        content: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('(0362) 22570'),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.email, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('koperasi@undiksha.ac.id'),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.message, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('0878-4224-6597'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildSection(
              title: 'Lokasi',
              icon: Icons.location_on,
              children: [
                _buildSettingTile(
                  icon: Icons.atm,
                  title: 'Lokasi ATM',
                  subtitle: 'Temukan ATM terdekat',
                  onTap: () {
                    // Implementasi peta ATM
                  },
                ),
                _buildSettingTile(
                  icon: Icons.business,
                  title: 'Lokasi Kantor',
                  subtitle: 'Temukan kantor cabang',
                  onTap: () {
                    // Implementasi peta kantor
                  },
                ),
              ],
            ),
            _buildSection(
              title: 'Tentang',
              icon: Icons.info,
              children: [
                _buildSettingTile(
                  icon: Icons.business_center,
                  title: 'Tentang Koperasi Undiksha',
                  subtitle: 'Informasi tentang koperasi',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Tentang Koperasi Undiksha'),
                        content: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Koperasi Undiksha adalah lembaga keuangan yang melayani seluruh civitas akademika Undiksha. Didirikan pada tahun 1970, koperasi ini telah melayani ribuan anggota dengan berbagai produk keuangan seperti simpanan, pinjaman, dan pembayaran.',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Visi:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text(
                                  'Menjadi koperasi terpercaya dan terdepan dalam melayani civitas akademika Undiksha',
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Misi:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text(
                                  '1. Memberikan pelayanan keuangan yang aman dan terpercaya\n2. Mengembangkan produk keuangan yang inovatif\n3. Meningkatkan kesejahteraan anggota',
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue[900], size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue[900]),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
