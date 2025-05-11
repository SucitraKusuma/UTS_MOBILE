// providers/nasabah_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NasabahProvider extends ChangeNotifier {
  String _nama = 'I Nyoman Sucitra Ananda Kusuma';
  double _saldo = 10000000000;
  String _nomorRekening = '2315091029';
  String _email = 'sucitra@undiksha.ac.id';
  String _telepon = '0878-1234-1024';
  String _alamat = 'Jl. Pulau Nila, Penarukan, Singaraja, Bali';
  String _username = '123';
  String _password = '123';

  // Getters
  String get nama => _nama;
  double get saldo => _saldo;
  String get nomorRekening => _nomorRekening;
  String get email => _email;
  String get telepon => _telepon;
  String get alamat => _alamat;
  String get username => _username;
  String get password => _password;

  // Setters
  void updateSaldo(double saldoBaru) {
    _saldo = saldoBaru;
    saveToPrefs();
    notifyListeners();
  }

  void updateProfil({
    String? nama,
    String? email,
    String? telepon,
    String? alamat,
  }) {
    if (nama != null) _nama = nama;
    if (email != null) _email = email;
    if (telepon != null) _telepon = telepon;
    if (alamat != null) _alamat = alamat;
    saveToPrefs();
    notifyListeners();
  }

  void updateKredensial({
    String? username,
    String? password,
  }) {
    if (username != null) _username = username;
    if (password != null) _password = password;
    saveToPrefs();
    notifyListeners();
  }

  // Persistence
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('saldo', _saldo);
    await prefs.setString('nama', _nama);
    await prefs.setString('email', _email);
    await prefs.setString('telepon', _telepon);
    await prefs.setString('alamat', _alamat);
    await prefs.setString('username', _username);
    await prefs.setString('password', _password);
    await prefs.setBool('is_logged_in', true);
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _saldo = prefs.getDouble('saldo') ?? _saldo;
    _nama = prefs.getString('nama') ?? _nama;
    _email = prefs.getString('email') ?? _email;
    _telepon = prefs.getString('telepon') ?? _telepon;
    _alamat = prefs.getString('alamat') ?? _alamat;
    _username = prefs.getString('username') ?? _username;
    _password = prefs.getString('password') ?? _password;
    notifyListeners();
  }

  // Validasi login
  bool validateLogin(String username, String password) {
    return username == _username && password == _password;
  }
}
