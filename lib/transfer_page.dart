// transfer_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/nasabah_provider.dart';
import 'providers/transaksi_provider.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _rekeningController = TextEditingController();
  final _jumlahController = TextEditingController();

  void _transferSaldo(BuildContext context) {
    final saldo = context.read<NasabahProvider>().saldo;
    final jumlah = double.tryParse(
            _jumlahController.text.replaceAll(',', '').replaceAll('.', '')) ??
        0;
    final rekening = _rekeningController.text.trim();

    if (jumlah <= 0 || rekening.isEmpty) {
      _showDialog('Nomor rekening atau jumlah transfer tidak valid');
      return;
    }

    if (jumlah > saldo) {
      _showDialog('Saldo Anda tidak cukup');
    } else {
      final formattedJumlah = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 2,
      ).format(jumlah);

      // Tampilkan konfirmasi
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Konfirmasi Transfer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Apakah Anda yakin ingin mentransfer'),
              const SizedBox(height: 8),
              Text(
                '$formattedJumlah',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('ke rekening: $rekening'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // batal
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<NasabahProvider>().updateSaldo(saldo - jumlah);

                // Tambahkan transaksi ke TransaksiProvider
                final transaksi = Transaksi(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  jenis: 'transfer',
                  jumlah: jumlah,
                  deskripsi: 'Transfer ke rekening $rekening',
                  tanggal: DateTime.now(),
                  status: 'berhasil',
                );
                context.read<TransaksiProvider>().addTransaksi(transaksi);

                Navigator.pop(context); // tutup dialog konfirmasi
                _showDialog(
                    'Transfer berhasil ke rekening $rekening sejumlah $formattedJumlah');
                _rekeningController.clear();
                _jumlahController.clear();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Ya, Transfer'),
            ),
          ],
        ),
      );
    }
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
        title:
            const Text('Transfer Saldo', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Saldo Saat Ini: $formattedSaldo',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _rekeningController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nomor Rekening Tujuan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Transfer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _transferSaldo(context),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'Transfer',
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
