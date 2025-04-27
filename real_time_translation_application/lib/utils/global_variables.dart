import 'package:flutter/material.dart';
import 'package:real_time_translation_application/screens/keypad_screen.dart';
import 'package:real_time_translation_application/screens/recent_screen.dart';
import 'package:real_time_translation_application/screens/contacts_screen.dart';

// List of screens for the bottom navigation
List<Widget> homeScreenItems = [
  const KeypadScreen(),
  const RecentScreen(),
  const ContactsScreen(),
];
