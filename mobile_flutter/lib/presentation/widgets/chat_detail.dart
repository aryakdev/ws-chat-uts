import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/model/chat_user_model.dart';
import 'package:mobile_flutter/presentation/widgets/empty_chat_view.dart';
import 'package:mobile_flutter/controllers/chat_detail.controller.dart';
import 'package:mobile_flutter/controllers/messages_controller.dart';
// import 'package:mobile_flutter/services/websocket_service.dart';
import 'package:mobile_flutter/services/api_client.dart';
import 'package:mobile_flutter/services/profile_providers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDetailView extends StatefulWidget {
   const ChatDetailView({
    super.key,
    required this.isDark,
    required this.selectedChat,
    required this.controller,
  });

  final bool isDark;
  final ChatRoomModel? selectedChat;
  final ChatDashboardController controller;
  static const _kDarkBg = Color(0xFF121212);
  static const _kDarkSurface = Color(0xFF1E1E1E);

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final TextEditingController messageController = TextEditingController();

  @override
void didUpdateWidget(covariant ChatDetailView oldWidget) {
  super.didUpdateWidget(oldWidget);

  final oldId = oldWidget.selectedChat?.id;
  final newId = widget.selectedChat?.id;

  if (oldId != newId && widget.selectedChat != null) {
    debugPrint("🔄 ROOM CHANGED");
    debugPrint("OLD: $oldId");
    debugPrint("NEW: $newId");

    _initializeChat(widget.selectedChat!);
  }
}

  @override
void initState() {
  super.initState();

  final chat = widget.selectedChat;
  if (chat == null) return;

  _initializeChat(chat);
}

Future<void> _initializeChat(ChatRoomModel chat) async {
  final cubit = context.read<MessageCubit>();
  cubit.disconnectSocket();
  cubit.reset(); 
  final token = await ApiClient().getAccessToken() ?? '';
  
  final roomId = await widget.controller.openRoom(chat);

  if (roomId == null) {
    debugPrint(" Gagal dapat roomId");
    return;
  }

  debugPrint("ROOM ID: $roomId");
  debugPrint("TOKEN: $token");

  await cubit.loadMessages(roomId, token);
  cubit.bindWebSocket(roomId);
}

@override
void dispose() {
  context.read<MessageCubit>().disconnectSocket();
  messageController.dispose();
  super.dispose();
}

  Widget _buildInputBar() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: widget.isDark ? ChatDetailView._kDarkSurface : Colors.white,
      border: Border(
        top: BorderSide(
          color: widget.isDark ? Colors.white12 : const Color(0xFFEFEFEF),
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            decoration: InputDecoration(
              
              hintText: "Message",
              hintStyle: TextStyle(
                color: widget.isDark ? Colors.white30 : Colors.grey,
                fontSize: 15,
              ),
       
              filled: true,
              fillColor: widget.isDark 
                  ? const Color(0xFF2A2A2A) 
                  : const Color(0xFFF4F4F4),
              
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),

              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min, // 
                children: [
                  const SizedBox(width: 8), 
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(CupertinoIcons.smiley),
                    iconSize: 22,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(CupertinoIcons.camera), 
                    iconSize: 22,
                  ),
                ],
              ),

              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      final text = messageController.text.trim();

                      debugPrint("=== SEND BUTTON CLICKED ===");
                      debugPrint("Text input: $text");

                      if (text.isEmpty) {
                        debugPrint("Text kosong, batal kirim");
                        return;
                      }

                      debugPrint("Calling controller.sendMessage...");

                      widget.controller.sendMessage(
                        content: text,
                      );

                      debugPrint("Message sent to controller");

                      messageController.clear();

                      debugPrint("Input cleared");
                      debugPrint("===========================");
                    },
                    icon: const Icon(CupertinoIcons.paperplane_fill),
                    iconSize: 22,
                  ),
                  IconButton(onPressed: () {},
                  icon: const Icon(CupertinoIcons.add),
                  iconSize: 22,
                  )
                ],
              )
            ),
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? ChatDetailView._kDarkBg : const Color(0xFFF2F2F7);
    final surfaceBg = widget.isDark ? ChatDetailView._kDarkSurface : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor = widget.isDark ? Colors.white54 : Colors.grey;

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: bg,
      body: Container(
        color: surfaceBg,
        child: widget.selectedChat == null
            ? EmptyChatView(isDark: widget.isDark)
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: widget.isDark ? Colors.white12 : const Color(0xFFEFEFEF),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        
                        if (isMobile)
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(CupertinoIcons.back),
                          ),

                        CircleAvatar(
                          radius: 22,
                          child: Text(widget.selectedChat!.name[0].toUpperCase()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.selectedChat!.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        ),
                        Icon(CupertinoIcons.phone, color: subColor),
                      ],
                    ),
                  ),

                  Expanded(
                    child: BlocBuilder<MessageCubit, MessageState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state.messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  child: Text(
                                    widget.selectedChat!.name[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.selectedChat!.name,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No messages yet. Start the conversation!",
                                  style: TextStyle(
                                    color: subColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[state.messages.length - 1 - index];
                            final currentUserId = context.read<ProfileProvider>().userId;
                            final isCurrentUser = message.senderId == currentUserId;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Align(
                                alignment: isCurrentUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser
                                        ? (widget.isDark
                                            ? Colors.blue.shade700
                                            : Colors.blue.shade500)
                                        : (widget.isDark
                                            ? const Color(0xFF2A2A2A)
                                            : Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isCurrentUser
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.content,
                                        style: TextStyle(
                                          color: isCurrentUser
                                              ? Colors.white
                                              : textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatTime(message.createdAt),
                                        style: TextStyle(
                                          color: isCurrentUser
                                              ? Colors.white70
                                              : Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _buildInputBar(),
                ],
              ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return "now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays == 1) {
      return "yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }
}
