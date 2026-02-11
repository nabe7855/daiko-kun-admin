import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'driver_registration_screen.dart';
import 'screens/driver_history_page.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daiko-kun Admin',
      // デバッグバナーを消す
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const DriverManagementPage(),
    const RideMonitorPage(),
    const Center(child: Text('Settings (Coming Soon)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('ダッシュボード'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('ドライバー管理'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_taxi),
                label: Text('配車監視'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('設定'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _totalSales = '...';
  String _activeDrivers = '...';
  String _completedRides = '...';
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchStats();
    });
  }

  Future<void> _fetchStats() async {
    try {
      // Fetch Rides
      final ridesResponse = await http.get(
        Uri.parse('http://localhost:8080/admin/ride-requests'),
      );
      if (ridesResponse.statusCode == 200) {
        final List<dynamic> rides = json.decode(ridesResponse.body);

        int completedCount = 0;
        double totalSales = 0;

        for (var ride in rides) {
          if (ride['status'] == 'completed') {
            completedCount++;
            // amount is either actual_fare or estimated_fare
            totalSales += (ride['actual_fare'] ?? ride['estimated_fare'] ?? 0)
                .toDouble();
          }
        }

        if (mounted) {
          final formatter = NumberFormat.currency(
            locale: 'ja_JP',
            symbol: '¥',
            decimalDigits: 0,
          );
          setState(() {
            _completedRides = '$completedCount 件';
            _totalSales = formatter.format(totalSales);
          });
        }
      }

      // Fetch Drivers
      final driversResponse = await http.get(
        Uri.parse('http://localhost:8080/admin/drivers'),
      );
      if (driversResponse.statusCode == 200) {
        final List<dynamic> drivers = json.decode(driversResponse.body);
        final activeCount = drivers
            .where((d) => d['status'] == 'active')
            .length;

        if (mounted) {
          setState(() {
            _activeDrivers = '$activeCount / ${drivers.length}';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '本日の稼働状況',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchStats,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatCard(
                title: '総売上 (推定)',
                value: _totalSales,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: '稼働ドライバー',
                value: _activeDrivers,
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: '完了配車数',
                value: _completedRides,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverManagementPage extends StatefulWidget {
  const DriverManagementPage({super.key});

  @override
  State<DriverManagementPage> createState() => _DriverManagementPageState();
}

class _DriverManagementPageState extends State<DriverManagementPage> {
  List<dynamic> _drivers = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchDrivers();
    });
  }

  Future<void> _fetchDrivers() async {
    // 初回のみローディングを表示
    if (_drivers.isEmpty && _isLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/admin/drivers'),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _drivers = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        debugPrint('Failed to load drivers: ${response.statusCode}');
        // エラー時は何もしない（ポーリングで回復するまで待つ）か、初回のみスナックバー
      }
    } catch (e) {
      debugPrint('Error fetching drivers: $e');
      // エラー時も同様
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ドライバー管理'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchDrivers),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drivers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('登録済みドライバーはいません'),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const DriverRegistrationScreen(),
                        ),
                      );
                      _fetchDrivers();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('新規ドライバー登録'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _drivers.length,
              itemBuilder: (context, index) {
                final driver = _drivers[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(driver['name'] ?? '名前なし'),
                  subtitle: Text(
                    '📞 ${driver['phone_number']} / 免許: ${driver['license_number']}',
                  ),
                  trailing: Chip(
                    label: Text(driver['status'] ?? 'unknown'),
                    backgroundColor: driver['status'] == 'active'
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverHistoryPage(driver: driver),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: _drivers.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DriverRegistrationScreen(),
                  ),
                );
                _fetchDrivers();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class RideMonitorPage extends StatelessWidget {
  const RideMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('配車監視画面 (実装予定)'));
  }
}
