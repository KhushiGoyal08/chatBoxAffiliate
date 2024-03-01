import 'package:flutter/material.dart';

class ListTileWithNavigation extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;

  ListTileWithNavigation(
      {required this.icon, required this.text, required this.onTap});

  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _isSelected ? const Color(0xff102E44) : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: _isSelected ? Colors.white : Colors.black),
        title: Text(
          text,
          style: TextStyle(
            color: _isSelected ? Colors.white : Colors.black,
          ),
        ),

        // Navigate to the destination screen
      ),
    );
  }
}
