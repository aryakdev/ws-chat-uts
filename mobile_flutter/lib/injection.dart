import 'package:mobile_flutter/domain/repositories/message_repository.dart';
import 'package:mobile_flutter/domain/repositories/profile_repository.dart';
import 'package:mobile_flutter/services/api_client_services.dart';
import 'package:mobile_flutter/services/messages_service.dart';
import 'package:mobile_flutter/services/profile_service.dart';
import 'package:mobile_flutter/services/websocket_service.dart';
import 'package:mobile_flutter/controllers/api_client_controllers.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final apiController = ApiController(ApiClient());
  apiController.init();
  getIt.registerSingleton<ApiController>(apiController);

  getIt.registerLazySingleton<WebSocketService>(() => WebSocketService());
  getIt.registerLazySingleton<MessageRepository>(
    () => MessageService(ApiClient()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileService(ApiClient()),
  );
}