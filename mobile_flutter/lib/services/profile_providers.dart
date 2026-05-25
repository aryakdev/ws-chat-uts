import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_flutter/services/api_client.dart';
// import 'package:dio/dio.dart';

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
    final prefs = await SharedPreferences.getInstance();
    _email = prefs.getString('email') ?? '';
    _userId = prefs.getString('user_id') ?? '';
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