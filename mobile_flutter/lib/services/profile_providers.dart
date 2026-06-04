import 'package:flutter/material.dart';
import 'package:mobile_flutter/services/storage_io.dart' if (dart.library.html) 'package:mobile_flutter/services/storage_web.dart';
import 'package:mobile_flutter/services/api_client.dart';

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
        _username = response.data['username'];
        _bio = response.data['bio'];
        _avatar = response.data['avatar'];

        if (response.data['user_id'] != null) {
          _userId = response.data['user_id'].toString();
        } else if (response.data['id'] != null) {
          _userId = response.data['id'].toString();
        }
      }
    } catch (e) {
      debugPrint("Gagal fetch profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({required String name, required String bio, required String avatar}) async {
    if (_userId.isEmpty) return false;

    try {
      final response = await ApiClient().dio.patch('/api/profile/update/$_userId', data: {
        'username': name,
        'bio': bio,
        'avatar': avatar,
      });

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
}