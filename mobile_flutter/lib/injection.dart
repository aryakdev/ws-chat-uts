import 'package:mobile_flutter/domain/repositories/message_repository.dart';
import 'package:mobile_flutter/domain/repositories/profile_repository.dart';
import 'package:mobile_flutter/services/api_client.dart';
import 'package:mobile_flutter/services/messages_service.dart';
import 'package:mobile_flutter/services/profile_service.dart';
import 'package:mobile_flutter/services/websocket_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<WebSocketService>(() => WebSocketService());
  getIt.registerLazySingleton<MessageRepository>(
    () => MessageService(ApiClient()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileService(ApiClient()),
  );
}