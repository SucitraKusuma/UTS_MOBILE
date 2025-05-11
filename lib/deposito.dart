// deposito.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/nasabah_provider.dart';
import 'providers/transaksi_provider.dart';

class DepositoPage extends StatefulWidget {
  const DepositoPage({super.key});

  @override
  State<DepositoPage> createState() => _DepositoPageState();
}

class _DepositoPageState extends State<DepositoPage> {
  final _jumlahController = TextEditingController();
  final _tujuanController = TextEditingController();
  final _tokenController = TextEditingController();
  int _durasi = 12; // Default 12 bulan
  double _bunga = 0.05; // 5% per tahun
  double _totalDeposito = 0;
  double _bungaTotal = 0;

  @override
  void dispose() {
    _jumlahController.dispose();
    _tujuanController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _hitungDeposito() {
    if (_jumlahController.text.isEmpty) return;

    final jumlah = double.parse(_jumlahController.text);
    _bungaTotal = jumlah * _bunga * (_durasi / 12);
    _totalDeposito = jumlah + _bungaTotal;

    setState(() {});
  }

  void _deposito(BuildContext context) {
    final saldo = context.read<NasabahProvider>().saldo;
    final jumlah = double.tryParse(
            _jumlahController.text.replaceAll(',', '').replaceAll('.', '')) ??
        0;
    final tujuan = _tujuanController.text.trim();
    final token = _tokenController.text.trim();

    if (jumlah <= 0 || tujuan.isEmpty || token.isEmpty) {
      _showDialog('Jumlah deposito, tujuan, atau token tidak valid');
      return;
    }

    if (token != '123') {
      _showDialog('Token salah. Silakan coba lagi.');
      return;
    }

    final formattedJumlah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    ).format(jumlah);

    final formattedTotal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    ).format(_totalDeposito);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Deposito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin melakukan deposito:'),
            const SizedBox(height: 8),
            Text(
              formattedJumlah,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Untuk: $tujuan'),
            const SizedBox(height: 8),
            Text('Durasi: $_durasi bulan'),
            const SizedBox(height: 8),
            Text('Bunga: ${(_bunga * 100).toStringAsFixed(1)}% per tahun'),
            const SizedBox(height: 8),
            Text('Total Pencairan: $formattedTotal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
            onPressed: () {
              // Tambah saldo
              context.read<NasabahProvider>().updateSaldo(saldo + jumlah);

              // Tambahkan transaksi ke TransaksiProvider
              final transaksi = Transaksi(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                jenis: 'deposito',
                jumlah: jumlah,
                deskripsi: 'Deposito untuk $tujuan (${_durasi} bulan)',
                tanggal: DateTime.now(),
                status: 'berhasil',
              );
              context.read<TransaksiProvider>().addTransaksi(transaksi);

              Navigator.pop(context);
              _showDialog('Deposito berhasil sejumlah $formattedJumlah');
              _jumlahController.clear();
              _tujuanController.clear();
              _tokenController.clear();
            },
            child: const Text('Ya, Deposito'),
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
        title: const Text('Deposito', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo Saat Ini: $formattedSaldo',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Deposito',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'Masukkan jumlah yang ingin didepositokan',
              ),
              onChanged: (value) => _hitungDeposito(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tujuanController,
              decoration: const InputDecoration(
                labelText: 'Tujuan Deposito',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.savings),
                hintText: 'Contoh: Pendidikan, Rumah, dll',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Durasi Deposito',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _durasi.toDouble(),
              min: 3,
              max: 60,
              divisions: 19,
              label: '$_durasi bulan',
              onChanged: (value) {
                setState(() {
                  _durasi = value.toInt();
                  _hitungDeposito();
                });
              },
            ),
            Text('$_durasi bulan'),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Token',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            if (_totalDeposito > 0) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rincian Deposito',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bunga per Tahun:'),
                          Text(
                            '${(_bunga * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Bunga:'),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 2,
                            ).format(_bungaTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pencairan:'),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 2,
                            ).format(_totalDeposito),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _deposito(context),
                icon: const Icon(Icons.savings, color: Colors.white),
                label: const Text(
                  'Deposito',
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
