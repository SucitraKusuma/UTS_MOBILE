// menuUtama.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/nasabah_provider.dart';
import 'providers/transaksi_provider.dart';

class MenuUtama extends StatefulWidget {
  const MenuUtama({super.key});

  @override
  _MenuUtamaState createState() => _MenuUtamaState();
}

class _MenuUtamaState extends State<MenuUtama> {
  String namaNasabah = 'I Nyoman Sucitra Ananda Kusuma';

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan data sebelum logout
    final nasabahProvider =
        Provider.of<NasabahProvider>(context, listen: false);
    final transaksiProvider =
        Provider.of<TransaksiProvider>(context, listen: false);

    await nasabahProvider.saveToPrefs();
    await transaksiProvider.saveToPrefs();

    await prefs.remove('is_logged_in');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final saldo = context.watch<NasabahProvider>().saldo;

    final formattedSaldo = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    ).format(saldo);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Menu Utama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue[900],
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12),
            child: const Center(
              child: Text(
                'Koperasi Undiksha',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/Gambar.jpg'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nasabah",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(namaNasabah),
                        SizedBox(height: 6),
                        Text("Total Saldo Anda",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(formattedSaldo),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    buildMenuItem(context, Icons.account_balance_wallet,
                        'Cek Saldo', '/cek_saldo'),
                    buildMenuItem(context, Icons.send, 'Transfer', '/transfer'),
                    buildMenuItem(
                        context, Icons.savings, 'Deposito', '/menabung'),
                    buildMenuItem(context, Icons.credit_card, 'Pembayaran',
                        '/pembayaran'),
                    buildMenuItem(
                        context, Icons.attach_money, 'Pinjaman', '/pinjaman'),
                    buildMenuItem(
                        context, Icons.receipt_long, 'Mutasi', '/mutasi'),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildBottomIcon(context, Icons.settings, 'Setting', '/setting'),
                buildBottomIcon(context, Icons.qr_code, '', '/qrcode',
                    isCenter: true),
                buildBottomIcon(context, Icons.person, 'Profile', '/profile'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildMenuItem(
      BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100], // Warna latar belakang transparan/abu muda
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 64),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget buildBottomIcon(
      BuildContext context, IconData icon, String label, String route,
      {bool isCenter = false}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: isCenter ? Colors.blue[900] : Colors.transparent,
            radius: isCenter ? 28 : 22,
            child: Icon(icon,
                color: isCenter ? Colors.white : Colors.blue, size: 28),
          ),
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(label, style: TextStyle(fontSize: 12)),
            )
        ],
      ),
    );
  }
}
