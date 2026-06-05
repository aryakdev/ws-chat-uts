import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_flutter/domain/repositories/profile_repository.dart';
import 'package:mobile_flutter/controllers/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  final ImagePicker _picker = ImagePicker();

  ProfileCubit(this.repository) : super(ProfileInitial());

  Future<void> pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image == null) return;

      emit(ProfileLoading());

      final String newImageUrl = await repository.uploadProfilePicture(image);

      emit(ProfileUploadSuccess(newImageUrl));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}