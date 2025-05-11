// login.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'menuUtama.dart';
import 'providers/nasabah_provider.dart';
import 'providers/transaksi_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final nasabahProvider =
        Provider.of<NasabahProvider>(context, listen: false);
    final transaksiProvider =
        Provider.of<TransaksiProvider>(context, listen: false);

    if (username == 'Sucitra' && password == '2315091029') {
      // Simpan status login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);

      // Reset saldo ke nilai awal
      nasabahProvider.updateSaldo(10000000000);

      // Reset data ke kondisi awal
      await nasabahProvider.saveToPrefs();
      await transaksiProvider.resetTransaksi();

      // Inisialisasi data nasabah dan transaksi
      await nasabahProvider.loadFromPrefs();
      await transaksiProvider.loadFromPrefs();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuUtama()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau Password Salah')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.blue[900],
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Center(
              child: Text(
                'Koperasi Undiksha',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            'assets/logo_undiksha.png', // Ganti dengan path logo Undiksha di folder assets
            height: 150,
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
