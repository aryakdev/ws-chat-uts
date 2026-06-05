import 'package:flutter/foundation.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUploadSuccess extends ProfileState {
  final String imageUrl;
  ProfileUploadSuccess(this.imageUrl);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}