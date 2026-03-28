import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/platform_provider.dart';

class SuperDashboardPage extends ConsumerWidget {
  const SuperDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(platformProvider.notifier).fetchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snapshot.data;
        if (stats == null) {
          return const Center(child: Text('邨ｱ險医ョ繝ｼ繧ｿ縺ｮ蜿門ｾ励↓螟ｱ謨励＠縺ｾ縺励◆'));
        }

        final formatter = NumberFormat.currency(
          locale: 'ja_JP',
          symbol: 'ﾂ･',
          decimalDigits: 0,
        );

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '繝励Λ繝・ヨ繝輔か繝ｼ繝蜈ｨ菴鍋ｵｱ險・,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(
                    title: '邱丞刈逶滉ｼ夂､ｾ謨ｰ',
                    value: '${stats.totalCompanies} 遉ｾ',
                    icon: Icons.business,
                    color: Colors.indigo,
                  ),
                  _StatCard(
                    title: '邱冗ｨｼ蜒阪ラ繝ｩ繧､繝舌・',
                    value: '${stats.totalDrivers} 蜷・,
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: '邏ｯ險亥ｮ御ｺ・・霆・,
                    value: '${stats.totalRequests} 莉ｶ',
                    icon: Icons.local_taxi,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: '繝励Λ繝・ヨ繝輔か繝ｼ繝邱丞｣ｲ荳・,
                    value: formatter.format(stats.totalSales),
                    icon: Icons.payments,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(icon, color: color.withOpacity(0.7)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
