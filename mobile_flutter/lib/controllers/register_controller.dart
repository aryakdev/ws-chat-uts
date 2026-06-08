import 'package:flutter/material.dart';
import 'package:mobile_flutter/services/api_client_services.dart';

const _kBlue = Color(0xFF2C6BED);

class RegisterController extends ChangeNotifier {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool _hidePwd = true;
  bool get hidePwd => _hidePwd;

  bool _hideConfirm = true;
  bool get hideConfirm => _hideConfirm;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  void toggleHidePwd() {
    _hidePwd = !_hidePwd;
    notifyListeners();
  }

  void toggleHideConfirm() {
    _hideConfirm = !_hideConfirm;
    notifyListeners();
  }

  Future<void> register(BuildContext context) async {
    if (usernameCtrl.text.trim().isEmpty) {
      _error = 'Username wajib diisi';
      notifyListeners();
      return;
    }
    if (!emailCtrl.text.contains('@')) {
      _error = 'Format email tidak valid';
      notifyListeners();
      return;
    }
    if (passwordCtrl.text.length < 8) {
      _error = 'Password minimal 8 karakter';
      notifyListeners();
      return;
    }
    if (passwordCtrl.text != confirmCtrl.text) {
      _error = 'Password tidak cocok';
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(
        '/api/auth/register',
        data: {
          'username': usernameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'password': passwordCtrl.text,
        },
      );

      final data = res.data as Map<String, dynamic>;
      if (res.statusCode == 201) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat! Silakan login.'),
            backgroundColor: _kBlue,
          ),
        );
        Navigator.pop(context);
      } else {
        _error = data['Message'] ?? data['message'] ?? 'Pendaftaran gagal';
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
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }
}
