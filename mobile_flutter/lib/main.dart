import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_flutter/controllers/messages_controller.dart';
import 'package:mobile_flutter/services/messages_service.dart';
import 'package:mobile_flutter/services/websocket_service.dart';
import 'package:provider/provider.dart';

// Import internal project kamu
import 'package:mobile_flutter/services/api_client.dart';
import 'package:mobile_flutter/theme/theme_controller.dart';
import 'package:mobile_flutter/services/profile_providers.dart'; 
import 'package:mobile_flutter/presentation/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ThemeController.init();
  await ApiClient().init();

  final profileProvider = ProfileProvider();
  await profileProvider.initLocalData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: profileProvider,
        ),

        Provider<WebSocketService>(
          create: (_) => WebSocketService(),
        ),

        BlocProvider(
          create: (context) => MessageCubit(
            MessageService(),
            webSocketService: context.read<WebSocketService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Sinkronisasi Tema
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Chatup',
          debugShowCheckedModeBanner: false,
          themeMode: mode,

          // Konfigurasi Tema Terang
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2C6BED), 
              brightness: Brightness.light
            ),
            scaffoldBackgroundColor: const Color(0xFFFFFFFF),
            textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
          ),

          // Konfigurasi Tema Gelap
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2C6BED), 
              brightness: Brightness.dark
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          ),

          // Halaman Pertama yang Muncul
          home: const SplashScreen(),
        );
      },
    );
  }
}