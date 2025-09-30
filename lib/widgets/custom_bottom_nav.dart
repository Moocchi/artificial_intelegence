import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Helper to build icon + text
    Widget navItem({required IconData icon, required String label, required int index}) {
      final isSelected = selectedIndex == index;
      final color = isSelected ? const Color(0xFF79C171) : Colors.grey;
      return GestureDetector(
        onTap: () => onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    return BottomAppBar(
      color: const Color(0xFFFFFFFF),
      shape: const CircularNotchedRectangle(),
      notchMargin: 15.0,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: kBottomNavigationBarHeight + 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(icon: Icons.home, label: "Home", index: 0),
            navItem(icon: Icons.info_outline, label: "About Us", index: 1),
            const SizedBox(width: 40), // space for the notch/FAB
            navItem(icon: Icons.map, label: "Maps", index: 2),
            navItem(icon: Icons.list_alt, label: "Logs", index: 3),
          ],
        ),
      ),
    );
  }
}
