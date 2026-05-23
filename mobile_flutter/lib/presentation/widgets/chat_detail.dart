import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/model/chat_user_model.dart';
import 'package:mobile_flutter/presentation/widgets/empty_chat_view.dart';
import 'package:mobile_flutter/controllers/chat_dashboard_controllers.dart';

class ChatDetailView extends StatefulWidget {
   const ChatDetailView({
    super.key,
    required this.isDark,
    required this.selectedChat,
    // required this.roomId,
    required this.controller,
  });

  final bool isDark;
  final ChatRoomModel? selectedChat;
  // final String roomId;
  final ChatDashboardController controller;
  static const _kDarkBg = Color(0xFF121212);
  static const _kDarkSurface = Color(0xFF1E1E1E);

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final TextEditingController messageController = TextEditingController();

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
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40),
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

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Text("Lorem Ipsum"),
                                  SizedBox(height: 6),
                                  Text("Lorem Ipsum"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  _buildInputBar(),
                ],
              ),
      ),
    );
  }
}
