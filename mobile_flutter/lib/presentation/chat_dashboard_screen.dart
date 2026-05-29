// import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile_flutter/controllers/chat_detail.controller.dart';
import 'package:mobile_flutter/model/chat_user_model.dart';
import 'package:mobile_flutter/presentation/settings/setting_page.dart';
import 'package:mobile_flutter/presentation/widgets/chat_detail.dart';
import 'package:mobile_flutter/presentation/widgets/chat_list.dart';
import 'package:mobile_flutter/presentation/widgets/navbar.dart';
import 'package:mobile_flutter/theme/theme_controller.dart';
import 'package:mobile_flutter/presentation/widgets/empty_chat_view.dart';
import 'package:mobile_flutter/services/websocket_service.dart';

const _kBlue = Color(0xFF2C6BED);
const _kDarkBg = Color(0xFF121212);
const _kDarkSurface = Color(0xFF1E1E1E);
const _kDarkCard = Color(0xFF262626);

class ChatDashboardScreen extends StatefulWidget {
  const ChatDashboardScreen({super.key});

  @override
  State<ChatDashboardScreen> createState() => _ChatDashboardScreenState();
}

class _ChatDashboardScreenState extends State<ChatDashboardScreen> {
  int _selectedIndex = 0;
  late final ChatDashboardController _controller;

  @override
  void initState() {
    super.initState();

    print("INIT STATE JALAN");

    // Initialize controller immediately with shared WebSocketService
    try {
      final ws = context.read<WebSocketService>();
      _controller = ChatDashboardController(webSocketService: ws);
    } catch (_) {
      _controller = ChatDashboardController();
    }
    
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.init();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        _controller.clearSelectedChat();
      }
    });
  }

  Future<void> _openSettings() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingPage()));
    setState(() {});
  }

  Future<void> _onChatSelected(ChatRoomModel chat) async {
    final roomId = await _controller.openRoom(chat);
    if (roomId == null) {
      return;
    }

    if (!mounted) return;
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailView(
            isDark: ThemeController.isDark,
            selectedChat: chat,
            // roomId: roomId,
            controller: _controller,
            
          ),
        ),
      );
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (_, __, ___) {
        final isDark = ThemeController.isDark;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 600;

            return Scaffold(
              backgroundColor: isDark ? _kDarkBg : const Color(0xFFF2F2F7),
              appBar: isDesktop ? null : _buildMobileAppBar(isDark),
              body: isDesktop ? _buildDesktopLayout(isDark) : _buildMobileBody(isDark),
              bottomNavigationBar: isDesktop ? null : _buildMobileBottomNavigation(isDark),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        ChatNavigationRail(
          isDark: isDark,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onNavTap,
          onSettingsTap: _openSettings,
        ),
        Expanded(
          child: _selectedIndex == 0
              ? Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ChatListView(
                        isDark: isDark,
                        chats: _controller.chats,
                        selectedChat: _controller.selectedChat,
                        onChatSelected: _onChatSelected,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: _controller.selectedChat != null && _controller.selectedRoomId != null
                          ? ChatDetailView(
                              isDark: isDark,
                              selectedChat: _controller.selectedChat,
                              // roomId: _controller.selectedRoomId!,
                              controller: _controller,
                            )
                          : EmptyChatView(isDark: isDark),
                    ),
                  ],
                )
              : _CallsView(isDark: isDark),
        ),
      ],
    );
  }

  Widget _buildMobileBody(bool isDark) {
    if (_selectedIndex == 1) return _CallsView(isDark: isDark);
    return ChatListView(
      isDark: isDark,
      chats: _controller.chats,
      selectedChat: _controller.selectedChat,
      onChatSelected: _onChatSelected,
    );
  }

  PreferredSizeWidget _buildMobileAppBar(bool isDark) {
    final appBarBg = isDark ? _kDarkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

    return AppBar(
      backgroundColor: appBarBg,
      elevation: 0,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: _openSettings,
          child: CircleAvatar(
            backgroundColor: isDark ? _kDarkCard : const Color(0xFFE8EDF5),
            child: Icon(CupertinoIcons.person_fill, color: isDark ? Colors.white54 : _kBlue, size: 18),
          ),
        ),
      ),
      title: Text('Signal', style: TextStyle(fontWeight: FontWeight.w800, color: titleColor, fontSize: 20)),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.camera, color: _kBlue, size: 22)),
        IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.pencil, color: _kBlue, size: 20)),
      ],
    );
  }

  Widget _buildMobileBottomNavigation(bool isDark) {
    final navBg = isDark ? _kDarkSurface : Colors.white;
    
    return BottomNavigationBar(
      backgroundColor: navBg,
      currentIndex: _selectedIndex,
      onTap: _onNavTap,
      selectedItemColor: _kBlue,
      unselectedItemColor: isDark ? Colors.white38 : Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chat_bubble_2_fill),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.phone_fill),
          label: 'Calls',
        ),
      ],
    );
  }
}

class _CallsView extends StatelessWidget {
  const _CallsView({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor = isDark ? Colors.white38 : Colors.grey;

    return Container(
      color: isDark ? _kDarkBg : const Color(0xFFF2F2F7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.phone_fill, size: 64, color: isDark ? Colors.white12 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Belum ada panggilan', style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Riwayat panggilan akan muncul di sini', style: TextStyle(color: subColor, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}