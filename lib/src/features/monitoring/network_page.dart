import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:limit_kuota_by5/src/core/data/database_helper.dart';
import 'package:limit_kuota_by5/src/core/services/intent_helper.dart';
import 'package:limit_kuota_by5/src/features/monitoring/history_page.dart';

class Network extends StatefulWidget {
  const Network({super.key});

  @override
  State<Network> createState() => _NetworkState();
}

class _NetworkState extends State<Network> {
  static const platform = MethodChannel('limit_kuota/channel');

  String wifiUsage = "0.00 MB";
  String mobileUsage = "0.00 MB";

  double wifiPercent = 0.0;
  double mobilePercent = 0.0;

  final int dailyLimitBytes = 1024 * 1024 * 1024; // 1 GB

  Future<void> fetchUsage() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getTodayUsage');

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      int wifiBytes = result['wifi'] ?? 0;
      int mobileBytes = result['mobile'] ?? 0;

      await DatabaseHelper.instance.insertOrUpdate(
        todayDate,
        wifiBytes,
        mobileBytes,
      );

      setState(() {
        wifiUsage = _formatBytes(wifiBytes);
        mobileUsage = _formatBytes(mobileBytes);

        wifiPercent = wifiBytes / dailyLimitBytes;
        mobilePercent = mobileBytes / dailyLimitBytes;
      });

      await checkLimitAndWarn(mobileBytes);
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        _showPermissionDialog();
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0.00 MB";

    double mb = bytes / (1024 * 1024);

    if (mb > 1024) {
      return "${(mb / 1024).toStringAsFixed(2)} GB";
    }

    return "${mb.toStringAsFixed(2)} MB";
  }

  Future<void> checkLimitAndWarn(int currentUsage) async {
    if (currentUsage >= dailyLimitBytes) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Batas Kuota Tercapai!"),
          content: const Text(
            "Penggunaan data Anda sudah mencapai limit.\n\n"
            "Silakan aktifkan 'Set Data Limit' di pengaturan sistem.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Nanti"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                IntentHelper.openDataLimitSettings();
              },
              child: const Text("Buka Pengaturan"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _usageCard("WiFi Today", wifiUsage, Icons.wifi, wifiPercent),
            const SizedBox(height: 20),
            _usageCard(
              "Mobile Today",
              mobileUsage,
              Icons.signal_cellular_alt,
              mobilePercent,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: fetchUsage,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _usageCard(
    String title,
    String value,
    IconData icon,
    double percent,
  ) {
    Color progressColor;

    if (percent >= 0.8) {
      progressColor = Colors.red;
    } else if (percent >= 0.5) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${(percent * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent.clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Izin Diperlukan"),
          content: const Text(
            "Aplikasi membutuhkan izin akses penggunaan untuk membaca statistik data internet.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                fetchUsage();
              },
              child: const Text("Buka Pengaturan"),
            ),
          ],
        );
      },
    );
  }
}