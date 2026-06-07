import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_flutter/domain/repositories/profile_repository.dart';
import 'package:mobile_flutter/services/api_client_services.dart';
import 'package:http_parser/http_parser.dart';

class ProfileService implements ProfileRepository {
  final ApiClient apiClient;

  ProfileService(this.apiClient);

  @override
  Future<String> uploadProfilePicture(XFile file) async {
    String fileName = file.name;

    if (fileName.isEmpty) fileName = "avatar.png";
    
    String ext = "png";
    if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
      ext = "jpeg";
    } else if (!fileName.toLowerCase().endsWith('.png')) {
      fileName = "$fileName.png";
    }

    final bytes = await file.readAsBytes();

    final formData = FormData.fromMap({
      "avatar": MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: MediaType('image', ext), 
      ),
    });

    try {
      final response = await apiClient.dio.patch(
        '/api/profile/avatar',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          String? avatarUrl = responseData['avatar']?.toString();

          if ((avatarUrl == null || avatarUrl.isEmpty) && responseData['data'] != null) {
            final nestedData = responseData['data'];
            if (nestedData is Map<String, dynamic>) {
              avatarUrl = nestedData['avatar']?.toString() ??
                          nestedData['avatar_url']?.toString() ??
                          nestedData['url']?.toString();
            }
          }

          avatarUrl ??= responseData['avatar_url']?.toString() ?? responseData['url']?.toString();

          if (avatarUrl != null && avatarUrl.isNotEmpty) {
            return avatarUrl;
          } else {
            throw Exception("Server Go sukses, tapi Cloudinary gagal memproses gambar (URL Kosong).");
          }
        }
      }
      throw Exception("Respon server tidak dikenali: ${response.data}");
    } on DioException catch (e) {
      String errorMsg = e.message ?? "Error tidak diketahui";
      
      if (e.response != null && e.response?.data != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          errorMsg = responseData['message']?.toString() ?? responseData.toString();
        } else {
          errorMsg = responseData.toString();
        }
      }
      throw Exception("Ditolak Server: $errorMsg");
    } catch (e) {
      throw Exception("Gagal: $e");
    }
  }
}