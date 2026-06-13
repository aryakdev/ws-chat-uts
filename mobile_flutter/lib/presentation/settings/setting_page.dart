import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/profile_providers.dart';
import '../../theme/theme_controller.dart';
import '../auth/login_page.dart';
import 'package:mobile_flutter/services/storage_io.dart' if (dart.library.html) 'package:mobile_flutter/services/storage_web.dart';
// import 'package:mobile_flutter/services/api_client_services.dart';
import 'package:mobile_flutter/controllers/api_client_controllers.dart';
import 'package:mobile_flutter/injection.dart';

const _kBlue = Color(0xFF2C6BED);

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Memanggil data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  void _showEditDialog() {
    final profileProv = context.read<ProfileProvider>();
    final usernameCtrl = TextEditingController(text: profileProv.username);
    final bioCtrl = TextEditingController(text: profileProv.bio);
    XFile? selectedAvatar;
    ImageProvider<Object>? selectedAvatarPreview;
    bool isSaving = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Edit Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username'),
                  enabled: !isSaving,
                ),
                TextField(
                  controller: bioCtrl,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  enabled: !isSaving,
                ),
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: _kBlue,
                  backgroundImage: selectedAvatarPreview ??
                      ((profileProv.avatar != null && profileProv.avatar!.isNotEmpty)
                          ? NetworkImage(profileProv.avatar!)
                          : null),
                  child: selectedAvatarPreview == null &&
                          (profileProv.avatar == null || profileProv.avatar!.isEmpty)
                      ? const Icon(Icons.person, size: 44, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          try {
                            final image = await _imagePicker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );

                            if (image == null || !dialogContext.mounted) return;

                            final imageBytes = await image.readAsBytes();
                            if (!dialogContext.mounted) return;
                            setDialogState(() {
                              selectedAvatar = image;
                              selectedAvatarPreview = MemoryImage(imageBytes);
                              errorMessage = null;
                            });
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setDialogState(() {
                              errorMessage = 'Gagal memilih avatar: $e';
                            });
                          }
                        },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose Avatar'),
                ),
                if (selectedAvatar != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      selectedAvatar!.name,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (isSaving) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      setDialogState(() {
                        isSaving = true;
                        errorMessage = null;
                      });

                      final success = await profileProv.updateProfile(
                        name: usernameCtrl.text,
                        bio: bioCtrl.text,
                        avatar: profileProv.avatar ?? '',
                      );

                      if (!dialogContext.mounted) return;

                      if (!success) {
                        setDialogState(() {
                          isSaving = false;
                          errorMessage = 'Gagal menyimpan profil.';
                        });
                        return;
                      }

                      if (selectedAvatar != null) {
                        final avatarUploaded = await profileProv.uploadAvatar(
                          selectedAvatar!,
                        );
                        if (!dialogContext.mounted) return;

                        if (!avatarUploaded) {
                          setDialogState(() {
                            isSaving = false;
                            errorMessage = 'Gagal mengunggah avatar.';
                          });
                          return;
                        }
                      } else {
                        await profileProv.fetchProfile();
                        if (!dialogContext.mounted) return;
                      }

                      if (!context.mounted || !dialogContext.mounted) return;

                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil berhasil diperbarui.')),
                      );
                    },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch: Mendengarkan perubahan data di Provider
    final profileProv = context.watch<ProfileProvider>();
    final isDark = ThemeController.isDark;
    
    // Tampilan awal (Placeholder) jika data sedang loading atau null
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

  // --- Sub-Widgets untuk merapikan build method ---

  Widget _buildProfileCard(String name, String email, String bio, String initial, String? avatarUrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: _kBlue,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty) ? Text(initial, style: const TextStyle(fontSize: 24, color: Colors.white)) : null,
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
          setState(() {}); // Untuk refresh tema lokal halaman
        }
      ),
    );
  }

  Widget _buildSignOutTile() {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
      onTap: () async {
         getIt<ApiController>().logout;
        await storageRemove('user_id');
        await storageRemove('email');
        if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
      },
    );
  }
}
