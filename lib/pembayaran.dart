// pembayaran.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/nasabah_provider.dart';
import 'providers/transaksi_provider.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({super.key});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final _nomorController = TextEditingController();
  final _jumlahController = TextEditingController();
  String _selectedJenis = 'Listrik';
  final List<String> _jenisPembayaran = [
    'Listrik',
    'Air',
    'Internet',
    'Telepon',
    'TV Kabel',
    'Asuransi',
    'Pajak',
    'BPJS',
  ];

  void _prosesPembayaran(BuildContext context) {
    final saldo = context.read<NasabahProvider>().saldo;
    final jumlah = double.tryParse(
            _jumlahController.text.replaceAll(',', '').replaceAll('.', '')) ??
        0;
    final nomor = _nomorController.text.trim();

    if (jumlah <= 0 || nomor.isEmpty) {
      _showDialog('Nomor atau jumlah pembayaran tidak valid');
      return;
    }

    if (jumlah > saldo) {
      _showDialog('Saldo Anda tidak cukup');
      return;
    }

    final formattedJumlah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    ).format(jumlah);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Apakah Anda yakin ingin melakukan pembayaran'),
            const SizedBox(height: 8),
            Text(
              '$_selectedJenis',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Nomor: $nomor',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              formattedJumlah,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              context.read<NasabahProvider>().updateSaldo(saldo - jumlah);

              // Tambahkan transaksi ke TransaksiProvider
              final transaksi = Transaksi(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                jenis: 'pembayaran',
                jumlah: jumlah,
                deskripsi: 'Pembayaran $_selectedJenis - $nomor',
                tanggal: DateTime.now(),
                status: 'berhasil',
              );
              context.read<TransaksiProvider>().addTransaksi(transaksi);

              Navigator.pop(context);
              _showDialog(
                  'Pembayaran $_selectedJenis berhasil sejumlah $formattedJumlah');
              _nomorController.clear();
              _jumlahController.clear();
            },
            child: const Text('Ya, Bayar'),
          ),
        ],
      ),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Informasi'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saldo = context.watch<NasabahProvider>().saldo;
    final formattedSaldo =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2)
            .format(saldo);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Saat Ini: $formattedSaldo',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedJenis,
                  isExpanded: true,
                  items: _jenisPembayaran.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedJenis = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nomorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nomor $_selectedJenis',
                border: const OutlineInputBorder(),
                hintText: 'Masukkan nomor $_selectedJenis',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Pembayaran',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _prosesPembayaran(context),
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text(
                  'Bayar',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
