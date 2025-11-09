import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/providers/auth_provider.dart';
import 'package:bookswap_app/providers/book_provider.dart';
import 'package:bookswap_app/providers/swap_provider.dart';
import 'package:bookswap_app/screens/main/browse_listings_screen.dart';
import 'package:bookswap_app/screens/main/my_listings_screen.dart';
import 'package:bookswap_app/screens/main/chats_screen.dart';
import 'package:bookswap_app/screens/main/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    BrowseListingsScreen(),
    MyListingsScreen(),
    ChatsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.user != null) {
        bookProvider.initialize(authProvider.user!.id);
        swapProvider.initialize(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}