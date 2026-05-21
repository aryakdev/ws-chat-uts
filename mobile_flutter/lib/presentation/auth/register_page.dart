// dart:convert removed; ApiClient handles encoding
import 'package:flutter/material.dart';
import 'package:mobile_flutter/services/api_client.dart';
import 'package:mobile_flutter/theme/theme_controller.dart';

const _kBlue      = Color(0xFF2C6BED);
const _kBlueDark  = Color(0xFF1A56D6);
const _kBubbleB   = Color(0xFFAEC6F6);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _hidePwd     = true;
  bool _hideConfirm = true;
  bool _loading     = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── REGISTER LOGIC ────────────────────────────────────────────────────────
  Future<void> _register() async {
    if (_usernameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Username wajib diisi'); return;
    }
    if (!_emailCtrl.text.contains('@')) {
      setState(() => _error = 'Format email tidak valid'); return;
    }
    if (_passwordCtrl.text.length < 8) {
      setState(() => _error = 'Password minimal 8 karakter'); return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Password tidak cocok'); return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient().post(
        '/api/auth/register',
        data: {
          'username': _usernameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passwordCtrl.text,
        },
      );

      final data = res.data as Map<String, dynamic>;
      if (res.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat! Silakan login.'),
            backgroundColor: _kBlue,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() => _error = data['Message'] ?? data['message'] ?? 'Pendaftaran gagal');
      }
    } catch (e) {
      setState(() => _error = 'Terjadi Kesalahan Koneksi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Menggunakan ValueListenableBuilder agar UI merespon perubahan themeNotifier
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, mode, child) {
        final isDark = mode == ThemeMode.dark;
        
        // Konstanta warna berdasarkan state isDark
        final bg       = isDark ? const Color(0xFF121212) : Colors.white;
        final cardBg   = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final text     = isDark ? Colors.white : const Color(0xFF1B1B1B);
        final hint     = isDark ? Colors.white54 : const Color(0xFF8696A0);
        final fill     = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F6FD);
        final border   = isDark ? Colors.white12 : const Color(0xFFD1D7DB);
        final bubbleA  = isDark ? const Color(0xFF1A3A6B) : _kBlue;
        final bubbleB  = isDark ? const Color(0xFF0D2040) : _kBubbleB;

        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              // Dekorasi atas-kiri
              Positioned(top: -80, left: -80,
                  child: _bubble(220, bubbleA, opacity: 0.85)),
              Positioned(top: 30, left: -40,
                  child: _bubble(120, bubbleB, opacity: 0.5)),
              // Dekorasi bawah-kanan
              Positioned(bottom: -90, right: -80,
                  child: _bubble(240, bubbleA, opacity: 0.7)),
              Positioned(bottom: 40, right: -30,
                  child: _bubble(130, bubbleB, opacity: 0.45)),

              // Toggle dark/light
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, right: 12),
                    child: _ThemeToggleBtn(isDark: isDark),
                  ),
                ),
              ),

              // Tombol back
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: text,
                          size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              // Konten
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 60, 28, 28),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha : isDark ? 0.4 : 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_kBlue, _kBlueDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _kBlue.withValues(
                                    alpha : 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: const Icon(Icons.person_add_rounded,
                                color: Colors.white, size: 34),
                          ),
                          const SizedBox(height: 18),

                          Text('Buat Akun',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: text,
                                  letterSpacing: 0.4)),
                          const SizedBox(height: 6),
                          Text('Daftar untuk mulai mengobrol',
                              style: TextStyle(fontSize: 13, color: hint)),
                          const SizedBox(height: 28),

                          _field(controller: _usernameCtrl,
                              hint: 'Username',
                              icon: Icons.person_outline_rounded,
                              action: TextInputAction.next,
                              fill: fill, border: border,
                              textColor: text, hintColor: hint),
                          const SizedBox(height: 12),

                          _field(controller: _emailCtrl,
                              hint: 'Email',
                              icon: Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                              action: TextInputAction.next,
                              fill: fill, border: border,
                              textColor: text, hintColor: hint),
                          const SizedBox(height: 12),

                          _field(controller: _passwordCtrl,
                              hint: 'Password (min. 8 karakter)',
                              icon: Icons.lock_outline_rounded,
                              obscure: _hidePwd,
                              action: TextInputAction.next,
                              fill: fill, border: border,
                              textColor: text, hintColor: hint,
                              suffix: IconButton(
                                icon: Icon(
                                  _hidePwd
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: hint, size: 20),
                                onPressed: () =>
                                    setState(() => _hidePwd = !_hidePwd),
                              )),
                          const SizedBox(height: 12),

                          _field(controller: _confirmCtrl,
                              hint: 'Konfirmasi Password',
                              icon: Icons.lock_outline_rounded,
                              obscure: _hideConfirm,
                              fill: fill, border: border,
                              textColor: text, hintColor: hint,
                              onSubmit: (_) => _register(),
                              suffix: IconButton(
                                icon: Icon(
                                  _hideConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: hint, size: 20),
                                onPressed: () =>
                                    setState(() => _hideConfirm = !_hideConfirm),
                              )),

                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            _errorBox(_error!),
                          ],
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity, height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: _loading
                                  ? const SizedBox(width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white))
                                  : const Text('Daftar',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(height: 18),

                          Row(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text('Sudah punya akun? ',
                                style: TextStyle(color: hint, fontSize: 14)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text('Masuk',
                                  style: TextStyle(
                                      color: _kBlue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bubble(double size, Color color, {double opacity = 1}) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(
            alpha : opacity),
        ),
      );

  Widget _errorBox(String msg) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(msg,
              style: const TextStyle(color: Colors.red, fontSize: 13))),
        ]),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
    TextInputAction? action,
    bool obscure = false,
    Widget? suffix,
    void Function(String)? onSubmit,
    required Color fill,
    required Color border,
    required Color textColor,
    required Color hintColor,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboard,
        textInputAction: action,
        obscureText: obscure,
        onSubmitted: onSubmit,
        style: TextStyle(color: textColor, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          prefixIcon: Icon(icon, color: hintColor, size: 20),
          suffixIcon: suffix,
          filled: true,
          fillColor: fill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBlue, width: 1.8)),
        ),
      );
}

// ─── TOGGLE BTN ───────────────────────────────────────────────────────────────
class _ThemeToggleBtn extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleBtn({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Memanggil fungsi toggle dari ThemeController Anda
        ThemeController.toggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        width: 64, height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? _kBlue : const Color(0xFFE0E0E0),
        ),
        child: Stack(children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                size: 14,
                color: isDark ? _kBlue : Colors.orange,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}