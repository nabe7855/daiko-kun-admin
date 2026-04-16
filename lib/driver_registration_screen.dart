import 'dart:convert';
import 'package:daiko_kun_shared/daiko_kun_shared.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'providers/auth_provider.dart';

class DriverRegistrationScreen extends ConsumerStatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  ConsumerState<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState
    extends ConsumerState<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = ref.read(authProvider).token;

    try {
      if (token == null) {
        throw Exception('隱崎ｨｼ繝医・繧ｯ繝ｳ縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/drivers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _nameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'license_number': _licenseController.text.trim(),
        }),
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('繝峨Λ繧､繝舌・繧堤匳骭ｲ縺励∪縺励◆'),
              backgroundColor: Colors.green,
            ),
          );
          _nameController.clear();
          _phoneController.clear();
          _licenseController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('逋ｻ骭ｲ縺ｫ螟ｱ謨励＠縺ｾ縺励◆: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('繧ｨ繝ｩ繝ｼ縺檎匱逕溘＠縺ｾ縺励◆: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('繝峨Λ繧､繝舌・譁ｰ隕冗匳骭ｲ')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '豌丞錐',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? '豌丞錐繧貞・蜉帙＠縺ｦ縺上□縺輔＞' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '髮ｻ隧ｱ逡ｪ蜿ｷ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.isEmpty ? '髮ｻ隧ｱ逡ｪ蜿ｷ繧貞・蜉帙＠縺ｦ縺上□縺輔＞' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _licenseController,
                    decoration: const InputDecoration(
                      labelText: '驕玖ｻ｢蜈崎ｨｱ險ｼ逡ｪ蜿ｷ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? '蜈崎ｨｱ險ｼ逡ｪ蜿ｷ繧貞・蜉帙＠縺ｦ縺上□縺輔＞'
                        : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('逋ｻ骭ｲ縺吶ｋ', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }
}
