// providers/transaksi_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Transaksi {
  final String id;
  final String jenis; // 'transfer', 'deposito', 'pembayaran', 'pinjaman'
  final double jumlah;
  final String deskripsi;
  final DateTime tanggal;
  final String status; // 'berhasil', 'gagal', 'pending', 'disetujui'

  Transaksi({
    required this.id,
    required this.jenis,
    required this.jumlah,
    required this.deskripsi,
    required this.tanggal,
    required this.status,
  });

  // Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'jenis': jenis,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'deskripsi': deskripsi,
    };
  }

  // Konversi dari JSON
  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      jenis: json['jenis'],
      jumlah: json['jumlah'],
      deskripsi: json['deskripsi'],
      tanggal: DateTime.parse(json['tanggal']),
      status: json['status'],
    );
  }
}

class TransaksiProvider extends ChangeNotifier {
  List<Transaksi> _transaksiList = [];
  final String _transaksiKey = 'transaksi_list';

  List<Transaksi> get transaksiList => _transaksiList;

  // Menambah transaksi baru
  void addTransaksi(Transaksi transaksi) {
    _transaksiList.add(transaksi);
    saveToPrefs();
    notifyListeners();
  }

  // Mendapatkan transaksi berdasarkan jenis
  List<Transaksi> getTransaksiByJenis(String jenis) {
    return _transaksiList.where((t) => t.jenis == jenis).toList();
  }

  // Mendapatkan transaksi berdasarkan tanggal
  List<Transaksi> getTransaksiByTanggal(DateTime tanggal) {
    return _transaksiList
        .where((t) =>
            t.tanggal.year == tanggal.year &&
            t.tanggal.month == tanggal.month &&
            t.tanggal.day == tanggal.day)
        .toList();
  }

  // Mendapatkan total transaksi berdasarkan jenis
  double getTotalByJenis(String jenis) {
    return _transaksiList
        .where((t) => t.jenis == jenis)
        .fold(0, (sum, t) => sum + t.jumlah);
  }

  // Persistence
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final transaksiJson = _transaksiList.map((t) => t.toJson()).toList();
    await prefs.setString(_transaksiKey, jsonEncode(transaksiJson));
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final transaksiJson = prefs.getString(_transaksiKey);
    if (transaksiJson != null) {
      final List<dynamic> decoded = jsonDecode(transaksiJson);
      _transaksiList = decoded.map((item) => Transaksi.fromJson(item)).toList();
      notifyListeners();
    }
  }

  // Menghapus semua transaksi (untuk testing)
  void clearTransaksi() {
    _transaksiList.clear();
    saveToPrefs();
    notifyListeners();
  }

  Future<void> resetTransaksi() async {
    _transaksiList.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transaksiKey);
    notifyListeners();
  }
}
