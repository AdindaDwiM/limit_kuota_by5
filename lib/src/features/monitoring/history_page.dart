import 'package:flutter/material.dart';
import 'package:limit_kuota_by5/src/core/data/database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyList;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    _historyList = DatabaseHelper.instance.getHistory();
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0.00 MB";

    double mb = bytes / (1024 * 1024);

    if (mb > 1024) {
      return "${(mb / 1024).toStringAsFixed(2)} GB";
    }

    return "${mb.toStringAsFixed(2)} MB";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Penggunaan"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Belum ada riwayat data."),
            );
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.history,
                    color: Colors.blue,
                  ),
                  title: Text(
                    item['date'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("WiFi: ${_formatBytes(item['wifi'])}"),
                      Text("Mobile: ${_formatBytes(item['mobile'])}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}