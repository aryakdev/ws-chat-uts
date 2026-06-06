import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatNavigationRail extends StatelessWidget {
  const ChatNavigationRail({
    super.key,
    required this.isDark,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onSettingsTap,
  });

  final bool isDark;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSettingsTap;

  static const _kBlue = Color(0xFF2C6BED);
  static const _kDarkSurface = Color(0xFF1E1E1E);
  static const _kDarkCard = Color(0xFF262626);

  @override
  Widget build(BuildContext context) {
    final railBg = isDark ? _kDarkSurface : Colors.white;
    final unselectedColor = isDark ? Colors.white54 : Colors.grey;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: railBg,
      unselectedIconTheme: IconThemeData(color: unselectedColor),
      selectedIconTheme: const IconThemeData(color: _kBlue),
      unselectedLabelTextStyle: TextStyle(color: unselectedColor, fontSize: 11),
      selectedLabelTextStyle: const TextStyle(
        color: _kBlue,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      labelType: NavigationRailLabelType.all,
      indicatorColor: _kBlue.withValues(
        alpha : 0.12),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: GestureDetector(
          onTap: onSettingsTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: isDark ? _kDarkCard : const Color(0xFFE8EDF5),
            child: Icon(
              CupertinoIcons.person_fill,
              color: isDark ? Colors.white54 : _kBlue,
              size: 20,
            ),
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(CupertinoIcons.chat_bubble),
          selectedIcon: Icon(CupertinoIcons.chat_bubble_fill),
          label: Text('Chats'),
        ),
        NavigationRailDestination(
          icon: Icon(CupertinoIcons.phone),
          selectedIcon: Icon(CupertinoIcons.phone_fill),
          label: Text('Calls'),
        ),
      ],
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(CupertinoIcons.settings, color: unselectedColor, size: 24),
                  tooltip: 'Settings',
                  onPressed: onSettingsTap,
                ),
                Text('Settings', style: TextStyle(color: unselectedColor, fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
