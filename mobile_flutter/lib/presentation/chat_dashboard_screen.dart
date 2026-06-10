import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter/controllers/chat_detail.controller.dart';
import 'package:mobile_flutter/model/chat_user_model.dart';
import 'package:mobile_flutter/presentation/settings/setting_page.dart';
import 'package:mobile_flutter/presentation/widgets/chat_detail.dart';
import 'package:mobile_flutter/presentation/widgets/chat_list.dart';
import 'package:mobile_flutter/presentation/widgets/navbar.dart';
import 'package:mobile_flutter/theme/theme_controller.dart';
import 'package:mobile_flutter/presentation/widgets/empty_chat_view.dart';
import 'package:mobile_flutter/services/websocket_service.dart';
import 'package:mobile_flutter/controllers/messages_controller.dart';
import 'package:mobile_flutter/injection.dart';
import 'package:mobile_flutter/services/profile_providers.dart';

class DashboardState {
  final int selectedIndex;
  final int rebuildTrigger;
  DashboardState(this.selectedIndex, this.rebuildTrigger);
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardState(0, 0));
  void setIndex(int index) => emit(DashboardState(index, state.rebuildTrigger));
  void triggerRebuild() => emit(DashboardState(state.selectedIndex, state.rebuildTrigger + 1));
}

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: const _ChatDetailScreenContent(),
    );
  }
}

class _ChatDetailScreenContent extends StatefulWidget {
  const _ChatDetailScreenContent();

  @override
  State<_ChatDetailScreenContent> createState() => _ChatDetailScreenContentState();
}

class _ChatDetailScreenContentState extends State<_ChatDetailScreenContent> {
  late final ChatDetailController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });

    try {
      final cubit = context.read<MessageCubit>();
      _controller = ChatDetailController(
        webSocketService: getIt<WebSocketService>(),
        messageCubit: cubit,
      );
    } catch (_) {
      _controller = ChatDetailController(
        messageCubit: context.read<MessageCubit>(),
      );
    }
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.init();
    if (!mounted) return;
    context.read<DashboardCubit>().triggerRebuild();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    context.read<DashboardCubit>().setIndex(index);
    if (index != 0) {
      _controller.clearSelectedChat();
    }
  }

  Future<void> _openSettings() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingPage()));
    if (!mounted) return;
    context.read<DashboardCubit>().triggerRebuild();
  }

  Future<void> _onChatSelected(ChatRoomModel chat) async {
    _controller.selectChat(chat);
    if (!mounted) return;
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailView(
            isDark: ThemeController.isDark,
            selectedChat: chat,
            controller: _controller,
          ),
        ),
      );
    } else {
      context.read<DashboardCubit>().triggerRebuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (_, __, ___) {
        final isDark = ThemeController.isDark;

        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashboardState) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 600;

                return Scaffold(
                  backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7),
                  appBar: isDesktop ? null : _buildMobileAppBar(isDark, profileProv),
                  body: isDesktop ? _buildDesktopLayout(isDark, dashboardState.selectedIndex) : _buildMobileBody(isDark, dashboardState.selectedIndex),
                  bottomNavigationBar: isDesktop ? null : _buildMobileBottomNavigation(isDark, dashboardState.selectedIndex),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(bool isDark, int selectedIndex) {
    return Row(
      children: [
        ChatNavigationRail(
          isDark: isDark,
          selectedIndex: selectedIndex,
          onDestinationSelected: _onNavTap,
          onSettingsTap: _openSettings,
        ),
        Expanded(
          child: selectedIndex == 0
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
                      child: _controller.selectedChat != null
                          ? ChatDetailView(
                              isDark: isDark,
                              selectedChat: _controller.selectedChat,
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

  Widget _buildMobileBody(bool isDark, int selectedIndex) {
    if (selectedIndex == 1) return _CallsView(isDark: isDark);
    return ChatListView(
      isDark: isDark,
      chats: _controller.chats,
      selectedChat: _controller.selectedChat,
      onChatSelected: _onChatSelected,
    );
  }

  PreferredSizeWidget _buildMobileAppBar(bool isDark, ProfileProvider profileProv) {
    final appBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

    final avatarUrl = profileProv.avatar;
    final username = profileProv.username ?? "";
    final initial = username.isNotEmpty ? username[0].toUpperCase() : "?";

    return AppBar(
      backgroundColor: appBarBg,
      elevation: 0,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: _openSettings,
          child: CircleAvatar(
            backgroundColor: isDark ? const Color(0xFF262626) : const Color(0xFFE8EDF5),
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? Text(initial, style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF2C6BED), fontWeight: FontWeight.bold))
                : null,
          ),
        ),
      ),
      title: Text('Chatup', style: TextStyle(fontWeight: FontWeight.w800, color: titleColor, fontSize: 20)),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.camera, color: Color(0xFF2C6BED), size: 22)),
        IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.pencil, color: Color(0xFF2C6BED), size: 20)),
      ],
    );
  }

  Widget _buildMobileBottomNavigation(bool isDark, int selectedIndex) {
    final navBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return BottomNavigationBar(
      backgroundColor: navBg,
      currentIndex: selectedIndex,
      onTap: _onNavTap,
      selectedItemColor: const Color(0xFF2C6BED),
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
      color: isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7),
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