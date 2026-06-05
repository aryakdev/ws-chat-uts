import 'package:image_picker/image_picker.dart';

abstract class ProfileRepository {
  Future<String> uploadProfilePicture(XFile file);
}