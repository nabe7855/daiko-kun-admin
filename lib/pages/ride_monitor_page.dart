import 'package:flutter/material.dart';

class RideMonitorPage extends StatelessWidget {
  const RideMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配車監視・ライブモニター', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monitor_heart, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text('現在、リアルタイムの配車リクエストはありません', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: () {}, child: const Text('過去の取引履歴を確認する')),
          ],
        ),
      ),
    );
  }
}
