import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/profile_providers.dart';
import '../../theme/theme_controller.dart';
import '../auth/login_page.dart';
import 'package:mobile_flutter/services/storage_io.dart' if (dart.library.html) 'package:mobile_flutter/services/storage_web.dart';
import 'package:mobile_flutter/controllers/api_client_controllers.dart';
import 'package:mobile_flutter/injection.dart';
import 'package:mobile_flutter/presentation/widgets/profile_avatar.dart';

const _kBlue = Color(0xFF2C6BED);

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  void _showEditDialog() {
    final profileProv = context.read<ProfileProvider>();
    final usernameCtrl = TextEditingController(text: profileProv.username);
    final bioCtrl = TextEditingController(text: profileProv.bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final success = await profileProv.updateProfile(
                name: usernameCtrl.text,
                bio: bioCtrl.text,
                avatar: profileProv.avatar ?? '',
              );
              if (!context.mounted) return;
              if (success) {
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final isDark = ThemeController.isDark;
    
    final displayUsername = profileProv.username ?? "Loading...";
    final displayBio = profileProv.bio ?? "Belum ada bio";
    final initial = displayUsername.isNotEmpty ? displayUsername[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: profileProv.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileCard(displayUsername, profileProv.email, displayBio, initial, profileProv.avatar),
                const SizedBox(height: 20),
                _buildThemeTile(isDark),
                const SizedBox(height: 20),
                _buildSignOutTile(),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileCard(String name, String email, String bio, String initial, String? avatarUrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ProfileAvatar(
                  currentImageUrl: avatarUrl,
                  initialName: initial,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(email, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit, color: _kBlue), onPressed: _showEditDialog),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
              child: Text(bio),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(bool isDark) {
    return ListTile(
      leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
      title: const Text('Dark Mode'),
      trailing: Switch.adaptive(
        value: isDark, 
        onChanged: (val) async {
          await ThemeController.setDark(val);
          setState(() {}); 
        }
      ),
    );
  }

  Widget _buildSignOutTile() {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
      onTap: () async {
         getIt<ApiController>().logout();
        await storageRemove('user_id');
        await storageRemove('email');
        if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
      },
    );
  }
}