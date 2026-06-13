import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_flutter/services/storage_io.dart'
    if (dart.library.html) 'package:mobile_flutter/services/storage_web.dart';
import 'package:mobile_flutter/services/api_client_services.dart';
import 'package:mobile_flutter/services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  String _email = '';
  String _userId = '';
  String? _username;
  String? _bio;
  String? _avatar;
  bool _isLoading = false;

  String get email => _email;
  String get userId => _userId;
  String? get username => _username;
  String? get bio => _bio;
  String? get avatar => _avatar;
  bool get isLoading => _isLoading;

  Future<void> initLocalData() async {
    _email = await storageGetString('email') ?? '';
    final storedUserId = await storageGetString('user_id');
    if (storedUserId != null && storedUserId.isNotEmpty) {
      _userId = storedUserId;
    } else {
      final storedId = await storageGetString('id');
      _userId = storedId ?? '';
    }
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient().dio.get('/api/profile/me');
      if (response.statusCode == 200) {
        final data = response.data;

        // Debug: lihat semua field yang dikembalikan server
        debugPrint("=== PROFILE RESPONSE: $data");

        _username = data['username']?.toString();
        _bio = data['bio']?.toString();

        // Coba semua kemungkinan nama field avatar dari backend
        _avatar = data['avatar']?.toString() ??
            data['avatar_url']?.toString() ??
            data['avatarUrl']?.toString() ??
            data['profile_picture']?.toString() ??
            data['photo']?.toString();

        debugPrint("=== AVATAR URL PARSED: $_avatar");

        if (data['user_id'] != null) {
          _userId = data['user_id'].toString();
        } else if (data['id'] != null) {
          _userId = data['id'].toString();
        }
      }
    } catch (e) {
      debugPrint("Gagal fetch profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadAvatar(XFile avatarFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final avatarUrl = await ProfileService(
        ApiClient(),
      ).uploadProfilePicture(avatarFile);
      _avatar = avatarUrl;
      await fetchProfile();
      return true;
    } catch (e) {
      debugPrint("Upload Avatar Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String bio,
    required String avatar,
  }) async {
    try {
      final response = await ApiClient().dio.patch(
        '/api/profile/me',
        data: {
          'username': name,
          'bio': bio,
          'avatar': avatar,
        },
      );
      if (response.statusCode == 200) {
        _username = name;
        _bio = bio;
        _avatar = avatar;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
    return false;
  }

  Future<bool> uploadAvatar(XFile file) async {
    _isLoading = true;
    notifyListeners();
    try {
      String fileName = file.name;
      if (!fileName.contains('.')) {
        fileName = 'avatar.png'; // default fallback for web/gallery
      }

      MultipartFile multipartFile;
      if (kIsWeb) {
        multipartFile = await MultipartFile.fromBytes(
          await file.readAsBytes(),
          filename: fileName,
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap({
        "avatar": multipartFile,
      });

      final response = await ApiClient().dio.patch(
        '/api/profile/avatar',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final newAvatar = response.data['avatar'];
        _avatar = '$newAvatar?v=${DateTime.now().millisecondsSinceEpoch}';
        return true;
      }
    } catch (e) {
      debugPrint("Upload Avatar Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}