import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:mobile_flutter/controllers/profile_cubit.dart';
import 'package:mobile_flutter/controllers/profile_state.dart';
import 'package:mobile_flutter/services/profile_providers.dart';

class ProfileAvatar extends StatelessWidget {
  final String? currentImageUrl;
  final String initialName;

  const ProfileAvatar({
    super.key,
    required this.currentImageUrl,
    required this.initialName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is ProfileUploadSuccess) {
          context.read<ProfileProvider>().updateProfile(
            name: context.read<ProfileProvider>().username ?? '',
            bio: context.read<ProfileProvider>().bio ?? '',
            avatar: state.imageUrl,
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is ProfileLoading;
        String? displayUrl = currentImageUrl;

        if (state is ProfileUploadSuccess) {
          displayUrl = state.imageUrl;
        }

        return GestureDetector(
          onTap: isLoading ? null : () => context.read<ProfileCubit>().pickAndUploadImage(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF2C6BED),
                backgroundImage: (displayUrl != null && displayUrl.isNotEmpty)
                    ? NetworkImage(displayUrl)
                    : null,
                child: (displayUrl == null || displayUrl.isEmpty)
                    ? Text(
                        initialName,
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      )
                    : null,
              ),
              if (isLoading)
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.black45,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              if (!isLoading)
                Positioned(
                  bottom: 0,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}