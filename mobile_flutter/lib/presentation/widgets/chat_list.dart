import 'package:flutter/material.dart';
import 'package:mobile_flutter/model/chat_user_model.dart';
import 'package:mobile_flutter/utils/date_formatter.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({
    super.key,
    required this.isDark,
    required this.chats,
    required this.onChatSelected,
    this.selectedChat,
  });

  final bool isDark;
  final List<ChatRoomModel> chats;
  final ValueChanged<ChatRoomModel> onChatSelected;
  final ChatRoomModel? selectedChat;

  static const _kBlue = Color(0xFF2C6BED);
  static const _kDarkBg = Color(0xFF121212);
  static const _kDarkSurface = Color(0xFF1E1E1E);
  static const _kDarkCard = Color(0xFF262626);

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? _kDarkBg : const Color(0xFFF2F2F7);
    final cardBg = isDark ? _kDarkSurface : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor = isDark ? Colors.white54 : const Color(0xFF8696A0);
    final searchBg = isDark ? _kDarkCard : const Color(0xFFEBEEF5);
    final divider = isDark ? Colors.white12 : const Color(0xFFEEEEEE);

    return Container(
      color: bg,
      child: Column(
        children: [
          Container(
            color: cardBg,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              style: TextStyle(color: textColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: subColor, fontSize: 15),
                prefixIcon: Icon(Icons.search_rounded, color: subColor, size: 22),
                filled: true,
                fillColor: searchBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: cardBg,
              child: ListView.separated(
                itemCount: chats.length,
                separatorBuilder: (_, __) => Divider(
                  height: 0,
                  indent: 76,
                  endIndent: 16,
                  color: divider,
                ),
                itemBuilder: (context, i) {
                  final chat = chats[i];
                  final isSelected = selectedChat?.id == chat.id;

                  return Material(
                    color: isSelected ? _kBlue.withValues(
                      alpha : isDark ? 0.18 : 0.08) : Colors.transparent,
                    child: ListTile(
                      onTap: () => onChatSelected(chat),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: _Avatar(name: chat.name, isDark: isDark),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              chat.name,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            chat.lastMessage != null
                                ? formatTime(chat.lastMessage!.createdAt)
                                : "",
                            style: TextStyle(
                              color: chat.unreadCount > 0
                                  ? _kBlue
                                  : subColor,
                              fontSize: 12,
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              (chat.lastMessage != null && chat.lastMessage!.content.isNotEmpty)
                                  ? chat.lastMessage!.content
                                  : "Belum ada pesan",
                              style: TextStyle(
                                color: subColor,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: _kBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${chat.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.isDark});

  final String name;
  final bool isDark;

  static const _colors = [
    Color(0xFF2C6BED),
    Color(0xFF34C759),
    Color(0xFFFF9500),
    Color(0xFFFF2D55),
    Color(0xFF5856D6),
    Color(0xFF00C7BE),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[name.codeUnitAt(0) % _colors.length];
    return CircleAvatar(
      radius: 26,
      backgroundColor: color.withValues(
        alpha : isDark ? 0.85 : 0.9),
      child: Text(
        name[0].toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
      ),
    );
  }
}
