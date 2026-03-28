import 'package:flutter/material.dart';

class DriverManagementPage extends StatelessWidget {
  const DriverManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ドライバー名簿・管理', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add),
            label: const Text('新規登録'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Row(
              children: [
                Text('ドライバー ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                _buildStatus(index),
              ],
            ),
            subtitle: const Text('電話: 070-****-**** | 車種: トヨタ プリウス'),
            trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildStatus(int index) {
    final status = index % 2 == 0 ? 'オンライン' : 'オフライン';
    final color = index % 2 == 0 ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}
