import 'package:flutter/material.dart';
import 'package:mobile_flutter/services/storage_io.dart' if (dart.library.html) 'package:mobile_flutter/services/storage_web.dart';
import 'register_page.dart';
import '../chat_dashboard_screen.dart';
import 'package:mobile_flutter/theme/theme_controller.dart';
import 'package:mobile_flutter/services/api_client.dart';



const kSignalBlue       = Color(0xFF2C6BED);
const kSignalBlueDark   = Color(0xFF1A56D6);
const kBlueBubble       = Color(0xFFAEC6F6);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool    _hidePwd = true;
  bool    _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
  if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
    setState(() => _error = 'Email dan password wajib diisi');
    return;
  }

  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    // Perbaikan kurung di sini: sebelumnya ada extra ')' setelah post()
    final res = await ApiClient().dio.post(
      '/api/auth/login',
      data: {
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
      },
    );

    final data = res.data as Map<String, dynamic>;

    if (res.statusCode == 200) {
      // Mengambil token dengan fallback yang aman
      final accessToken = (data['access_token'] ?? data['token'])?.toString() ?? '';
      final refreshToken = data['refresh_token']?.toString() ?? '';

      if (accessToken.isEmpty) {
        setState(() => _error = 'Token login tidak valid');
        return;
      }

      // Pastikan method ini ada di ApiClient Anda
      await ApiClient().saveAuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      await storageSetString('user_id', data['user_id']?.toString() ?? '');
      await storageSetString('email', _emailCtrl.text.trim());

      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ChatDashboardScreen()),
        (route) => false,
      );
    } else {
      setState(() => _error = data['Message'] ?? data['message'] ?? 'Login gagal');
    }
  } catch (e) {
    // Menampilkan error asli jika perlu untuk debugging: e.toString()
    setState(() => _error = 'Terjadi Kesalahan Koneksi.');
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
   
    final isDark = ThemeController.isDark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bg = theme.scaffoldBackgroundColor;
    final cardBg = theme.cardColor;
    final textColor = colorScheme.onSurface;
    final hintColor = colorScheme.onSurfaceVariant;
    final inputFill = colorScheme.surface.withValues(
      alpha: isDark ? 0.24 : 0.9,
    );
    final borderColor = colorScheme.outline.withValues(
      alpha: isDark ? 0.45 : 0.4,
    );
    final bubbleA = colorScheme.primary;
    final bubbleB = colorScheme.primaryContainer;


    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned(
            top: -80, left: -80,
            child: _bubble(220, bubbleA, opacity: 0.85),
          ),
          Positioned(
            top: 30, left: -40,
            child: _bubble(120, bubbleB, opacity: 0.5),
          ),
          Positioned(
            bottom: -90, right: -80,
            child: _bubble(240, bubbleA, opacity: 0.7),
          ),
          Positioned(
            bottom: 40, right: -30,
            child: _bubble(130, bubbleB, opacity: 0.45),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _ThemeToggle(isDark: isDark),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                        alpha: isDark ? 0.4 : 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kSignalBlue, kSignalBlueDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kSignalBlue.withValues(
                                alpha :0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: const Icon(Icons.chat_rounded,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 18),

                      Text('Link',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Text('Masuk ke akun kamu',
                          style: TextStyle(fontSize: 14, color: hintColor)),
                      const SizedBox(height: 32),

                      _inputField(
                        controller: _emailCtrl,
                        hint: 'Email',
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        inputAction: TextInputAction.next,
                        fillColor: inputFill,
                        borderColor: borderColor,
                        textColor: textColor,
                        hintColor: hintColor,
                      ),
                      const SizedBox(height: 14),

                      _inputField(
                        controller: _passwordCtrl,
                        hint: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: _hidePwd,
                        fillColor: inputFill,
                        borderColor: borderColor,
                        textColor: textColor,
                        hintColor: hintColor,
                        onSubmit: (_) => _login(),
                        suffix: IconButton(
                          icon: Icon(
                            _hidePwd
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: hintColor, size: 20),
                          onPressed: () =>
                              setState(() => _hidePwd = !_hidePwd),
                        ),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        _errorBox(_error!),
                      ],
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSignalBlue,
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
                              : const Text('Masuk',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Text('Belum punya akun? ',
                            style: TextStyle(color: hintColor, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterPage())),
                          child: const Text('Daftar',
                              style: TextStyle(
                                  color: kSignalBlue,
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
  }
  }

  Widget _bubble(double size, Color color, {double opacity = 1}) => Container(
        width: size,
        height: size,
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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    TextInputAction? inputAction,
    bool obscure = false,
    Widget? suffix,
    void Function(String)? onSubmit,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    required Color hintColor,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: inputAction,
      obscureText: obscure,
      onSubmitted: onSubmit,
      style: TextStyle(color: textColor, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 15),
        prefixIcon: Icon(prefixIcon, color: hintColor, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: kSignalBlue, width: 1.8)),
      ),
    );
  }


class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  const _ThemeToggle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ThemeController.toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        width: 64,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? kSignalBlue : const Color(0xFFE0E0E0),
        ),
        child: Stack(children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            alignment:
                isDark ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                size: 14,
                color: isDark ? kSignalBlue : Colors.orange,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}