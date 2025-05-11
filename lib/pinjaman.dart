// pinjaman.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/transaksi_provider.dart';
import 'providers/nasabah_provider.dart';

class PinjamanPage extends StatefulWidget {
  const PinjamanPage({super.key});

  @override
  State<PinjamanPage> createState() => _PinjamanPageState();
}

class _PinjamanPageState extends State<PinjamanPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  int _durasi = 12; // Default 12 bulan
  double _bunga = 0.1; // 10% per tahun
  double _totalPinjaman = 0;
  double _angsuranBulanan = 0;

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  void _hitungPinjaman() {
    if (_jumlahController.text.isEmpty) return;

    final jumlah = double.parse(_jumlahController.text);
    final totalBunga = jumlah * _bunga * (_durasi / 12);
    _totalPinjaman = jumlah + totalBunga;
    _angsuranBulanan = _totalPinjaman / _durasi;

    setState(() {});
  }

  void _ajukanPinjaman() {
    if (!_formKey.currentState!.validate()) return;

    final jumlah = double.parse(_jumlahController.text);
    final nasabahProvider = context.read<NasabahProvider>();
    final transaksiProvider = context.read<TransaksiProvider>();

    // Tambah saldo nasabah
    nasabahProvider.updateSaldo(nasabahProvider.saldo + jumlah);

    // Buat transaksi pinjaman
    final transaksi = Transaksi(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jenis: 'pinjaman',
      jumlah: jumlah,
      deskripsi: 'Pinjaman ${_durasi} bulan',
      tanggal: DateTime.now(),
      status: 'berhasil',
    );

    transaksiProvider.addTransaksi(transaksi);

    // Tampilkan dialog sukses
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pinjaman Berhasil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Jumlah Pinjaman: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(jumlah)}'),
            Text('Durasi: $_durasi bulan'),
            Text(
                'Angsuran per Bulan: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(_angsuranBulanan)}'),
            Text(
                'Total Pinjaman: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(_totalPinjaman)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinjaman', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pinjaman',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jumlahController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Pinjaman',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon masukkan jumlah pinjaman';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Mohon masukkan angka yang valid';
                          }
                          return null;
                        },
                        onChanged: (value) => _hitungPinjaman(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Durasi Pinjaman',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: _durasi.toDouble(),
                        min: 6,
                        max: 60,
                        divisions: 9,
                        label: '$_durasi bulan',
                        onChanged: (value) {
                          setState(() {
                            _durasi = value.toInt();
                            _hitungPinjaman();
                          });
                        },
                      ),
                      Text('$_durasi bulan'),
                      const SizedBox(height: 16),
                      if (_totalPinjaman > 0) ...[
                        const Divider(),
                        const Text(
                          'Rincian Pinjaman',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Angsuran per Bulan:'),
                            Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp ',
                                decimalDigits: 2,
                              ).format(_angsuranBulanan),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pinjaman:'),
                            Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp ',
                                decimalDigits: 2,
                              ).format(_totalPinjaman),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _ajukanPinjaman,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Ajukan Pinjaman',
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
      ),
    );
  }
}
