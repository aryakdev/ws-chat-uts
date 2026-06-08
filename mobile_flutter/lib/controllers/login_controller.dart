import 'package:flutter/material.dart';
import 'package:mobile_flutter/services/storage_io.dart' if (dart.library.html) 'package:mobile_flutter/services/storage_web.dart';
import 'package:mobile_flutter/services/api_client_services.dart';
import 'package:mobile_flutter/presentation/chat_dashboard_screen.dart';

class LoginController extends ChangeNotifier {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool _hidePwd = true;
  bool get hidePwd => _hidePwd;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  void toggleHidePwd() {
    _hidePwd = !_hidePwd;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (emailCtrl.text.trim().isEmpty || passwordCtrl.text.isEmpty) {
      _error = 'Email dan password wajib diisi';
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiClient().dio.post(
        '/api/auth/login',
        data: {
          'email': emailCtrl.text.trim(),
          'password': passwordCtrl.text,
        },
      );

      final data = res.data as Map<String, dynamic>;

      if (res.statusCode == 200) {
        final accessToken = (data['access_token'] ?? data['token'])?.toString() ?? '';
        final refreshToken = data['refresh_token']?.toString() ?? '';

        if (accessToken.isEmpty) {
          _error = 'Token login tidak valid';
          _loading = false;
          notifyListeners();
          return;
        }

        await ApiClient().saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        await storageSetString('user_id', data['user_id']?.toString() ?? '');
        await storageSetString('email', emailCtrl.text.trim());

        if (!context.mounted) return;
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ChatDetailScreen()),
          (route) => false,
        );
      } else {
        _error = data['Message'] ?? data['message'] ?? 'Login gagal';
      }
    } catch (e) {
      _error = 'Terjadi Kesalahan Koneksi.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
}
