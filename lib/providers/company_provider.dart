import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'auth_provider.dart';

class CompanyStats {
  final int totalDrivers;
  final int totalRequests;
  final double totalSales;

  CompanyStats({
    required this.totalDrivers,
    required this.totalRequests,
    required this.totalSales,
  });

  factory CompanyStats.fromJson(Map<String, dynamic> json) {
    return CompanyStats(
      totalDrivers: json['total_drivers'] ?? 0,
      totalRequests: json['total_requests'] ?? 0,
      totalSales: (json['total_sales'] ?? 0).toDouble(),
    );
  }
}

class CompanyNotifier extends AsyncNotifier<CompanyStats?> {
  @override
  Future<CompanyStats?> build() async {
    return fetchStats();
  }

  String? get _token => ref.read(authProvider)?.token;

  Future<CompanyStats?> fetchStats() async {
    final token = _token;
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('http://10.68.139.36:8080/admin/company/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return CompanyStats.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error fetching company stats: $e');
    }
    return null;
  }

  Future<List<dynamic>> fetchDrivers() async {
    final token = _token;
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('http://10.68.139.36:8080/admin/drivers'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching drivers: $e');
    }
    return [];
  }

  Future<List<dynamic>> fetchRides() async {
    final token = _token;
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('http://10.68.139.36:8080/admin/ride-requests'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching rides: $e');
    }
    return [];
  }
}

final companyProvider = AsyncNotifierProvider<CompanyNotifier, CompanyStats?>(
  CompanyNotifier.new,
);
