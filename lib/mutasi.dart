// mutasi.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/transaksi_provider.dart';

class MutasiPage extends StatefulWidget {
  const MutasiPage({super.key});

  @override
  State<MutasiPage> createState() => _MutasiPageState();
}

class _MutasiPageState extends State<MutasiPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final transaksiProvider = context.watch<TransaksiProvider>();
    final transaksiList = transaksiProvider.transaksiList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutasi Transaksi',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'Semua', child: Text('Semua')),
              const PopupMenuItem(value: 'transfer', child: Text('Transfer')),
              const PopupMenuItem(value: 'deposito', child: Text('Deposito')),
              const PopupMenuItem(
                  value: 'pembayaran', child: Text('Pembayaran')),
              const PopupMenuItem(value: 'pinjaman', child: Text('Pinjaman')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                Text('Filter: $_selectedFilter'),
              ],
            ),
          ),
          Expanded(
            child: transaksiList.isEmpty
                ? const Center(
                    child: Text('Belum ada transaksi'),
                  )
                : ListView.builder(
                    itemCount: transaksiList.length,
                    itemBuilder: (context, index) {
                      final transaksi = transaksiList[index];
                      if (_selectedFilter != 'Semua' &&
                          transaksi.jenis != _selectedFilter) {
                        return const SizedBox.shrink();
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getColorByJenis(transaksi.jenis),
                            child: Icon(
                              _getIconByJenis(transaksi.jenis),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            transaksi.deskripsi,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy HH:mm')
                                .format(transaksi.tanggal),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 2,
                                ).format(transaksi.jumlah),
                                style: TextStyle(
                                  color: transaksi.jenis == 'deposito' ||
                                          transaksi.jenis == 'pinjaman'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                transaksi.status,
                                style: TextStyle(
                                  color: _getStatusColor(transaksi.status),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getColorByJenis(String jenis) {
    switch (jenis) {
      case 'transfer':
        return Colors.blue;
      case 'deposito':
        return Colors.green;
      case 'pembayaran':
        return Colors.orange;
      case 'pinjaman':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconByJenis(String jenis) {
    switch (jenis) {
      case 'transfer':
        return Icons.send;
      case 'deposito':
        return Icons.savings;
      case 'pembayaran':
        return Icons.payment;
      case 'pinjaman':
        return Icons.attach_money;
      default:
        return Icons.receipt;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'berhasil':
        return Colors.green;
      case 'gagal':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'disetujui':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
