import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class CompanyAdminState {
  final String id;
  final String companyId;
  final String name;
  final String role;
  final String token;

  CompanyAdminState({
    required this.id,
    required this.companyId,
    required this.name,
    required this.role,
    required this.token,
  });
}

class AuthNotifier extends Notifier<CompanyAdminState?> {
  @override
  CompanyAdminState? build() {
    return null; // 初期は未ログイン
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.68.139.36:8080/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];
        final user = body['user'];

        if (user['role'] != 'company_admin') return false; // 会社管琁E��E��外�E拒否

        state = CompanyAdminState(
          id: user['id'],
          companyId: user['company_id'],
          name: user['name'],
          role: user['role'],
          token: token,
        );
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  void logout() {
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, CompanyAdminState?>(
  AuthNotifier.new,
);
