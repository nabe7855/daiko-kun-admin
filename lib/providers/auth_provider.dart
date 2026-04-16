import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:daiko_kun_shared/daiko_kun_shared.dart';

class AuthState {
  final AdminUser? user;
  final String? token;

  AuthState({this.user, this.token});
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState(); // 初期は未ログイン
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.adminUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];
        final userData = body['user'];

        // 共通モデルを使用してデコード
        final user = AdminUser.fromJson(userData);

        // 会社管理者またはシステム管理者のみ許可
        if (user.role != 'company_admin' && user.role != 'super_admin') {
          return false; 
        }

        state = AuthState(user: user, token: token);
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
