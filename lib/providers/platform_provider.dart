import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daiko_kun_shared/daiko_kun_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlatformStats {
  final int totalCompanies;
  final int totalDrivers;
  final int totalRequests;
  final double totalSales;

  PlatformStats({
    required this.totalCompanies,
    required this.totalDrivers,
    required this.totalRequests,
    required this.totalSales,
  });

  factory PlatformStats.fromJson(Map<String, dynamic> json) {
    return PlatformStats(
      totalCompanies: json['total_companies'] ?? 0,
      totalDrivers: json['total_drivers'] ?? 0,
      totalRequests: json['total_requests'] ?? 0,
      totalSales: (json['total_sales'] ?? 0).toDouble(),
    );
  }
}

class Company {
  final String id;
  final String name;
  final String status;
  final double commissionRate;
  final DateTime createdAt;

  Company({
    required this.id,
    required this.name,
    required this.status,
    required this.commissionRate,
    required this.createdAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      commissionRate: (json['commission_rate'] ?? 10.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PlatformNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<PlatformStats?> fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/platform/stats'),
      );
      if (response.statusCode == 200) {
        return PlatformStats.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Fetch platform stats error: $e');
    }
    return null;
  }

  Future<List<Company>> fetchCompanies() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/platform/companies'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Company.fromJson(e)).toList();
      }
    } catch (e) {
      print('Fetch companies error: $e');
    }
    return [];
  }

  Future<bool> updateCompanyStatus(String id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/admin/platform/companies/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final platformProvider = AsyncNotifierProvider<PlatformNotifier, void>(
  PlatformNotifier.new,
);
