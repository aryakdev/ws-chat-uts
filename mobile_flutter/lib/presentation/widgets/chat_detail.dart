import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/model/chat_user.dart';
import 'package:mobile_flutter/presentation/widgets/empty_chat_view.dart';

class ChatDetailView extends StatelessWidget {
  const ChatDetailView({
    super.key,
    required this.isDark,
    required this.selectedChat,
    required this.roomId
  });

  final bool isDark;
  final ChatModel? selectedChat;
  final String roomId;

  static const _kDarkBg = Color(0xFF121212);
  static const _kDarkSurface = Color(0xFF1E1E1E);

  Widget _buildInputBar() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: isDark ? _kDarkSurface : Colors.white,
      border: Border(
        top: BorderSide(
          color: isDark ? Colors.white12 : const Color(0xFFEFEFEF),
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Message",
              hintStyle: TextStyle(
                color: isDark ? Colors.white30 : Colors.grey,
                fontSize: 15,
              ),
       
              filled: true,
              fillColor: isDark 
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


              // 2. Tombol Add (Di dalam input bar sebelah kanan)
              suffixIcon: IconButton(
                onPressed: () {
                  print("Add attachment clicked");
                },
                icon: const Icon(CupertinoIcons.add),
                iconSize: 22,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? _kDarkBg : const Color(0xFFF2F2F7);
    final surfaceBg = isDark ? _kDarkSurface : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subColor = isDark ? Colors.white54 : Colors.grey;

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: bg,
      body: Container(
        color: surfaceBg,
        child: selectedChat == null
            ? EmptyChatView(isDark: isDark)
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white12 : const Color(0xFFEFEFEF),
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
                          child: Text(selectedChat!.name[0].toUpperCase()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedChat!.name,
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
                                selectedChat!.name[0].toUpperCase(),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              selectedChat!.name,
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
                                color: isDark
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
