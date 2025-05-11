// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'menuUtama.dart';
import 'DummyPage.dart';
import 'providers/nasabah_provider.dart';
import 'cekSaldo.dart';
import 'transfer_page.dart';
import 'deposito.dart';
import 'mutasi.dart';
import 'pembayaran.dart';
import 'pinjaman.dart';
import 'profile.dart';
import 'setting.dart';
import 'providers/transaksi_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NasabahProvider()),
        ChangeNotifierProvider(create: (_) => TransaksiProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const MenuUtama() : const LoginPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/cek_saldo': (_) => const CekSaldoPage(),
        '/transfer': (_) => const TransferPage(),
        '/menabung': (_) => const DepositoPage(),
        '/pembayaran': (_) => const PembayaranPage(),
        '/pinjaman': (_) => const PinjamanPage(),
        '/mutasi': (_) => const MutasiPage(),
        '/setting': (_) => const SettingPage(),
        '/qrcode': (_) => const DummyPage(title: 'QR Code'),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
