import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function onMorePressed;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 14,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10), // Extra spacing above the title
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 14.0), // Add padding to move it down
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => onMorePressed(),
          ),
        ),
        const SizedBox(width: 10), // Alignment adjustment for icon and text
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65); // Set preferred size for AppBar
}
