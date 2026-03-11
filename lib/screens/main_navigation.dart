import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'reels/reels_screen.dart';
import 'auth/login_screen.dart';
import 'explore/explore_screen.dart';
import 'upload/upload_screen.dart';
import 'inbox/inbox_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ReelsScreen(),
    const ExploreScreen(),
    const UploadScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2 || index == 4) {
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _buildConnectionIndicator(connectivity),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house, size: 20),
            activeIcon: Icon(FontAwesomeIcons.houseUser, size: 20),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.magnifyingGlass, size: 20),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.squarePlus, size: 28),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.commentDots, size: 20),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user, size: 20),
            activeIcon: Icon(FontAwesomeIcons.userLarge, size: 20),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator(ConnectivityProvider connectivity) {
    Color color;
    String text;
    bool show = true;

    switch (connectivity.status) {
      case BackendStatus.checking:
        color = Colors.orange;
        text = "Checking connection...";
        break;
      case BackendStatus.online:
        color = Colors.green;
        text = "Connected to Backend";
        show = false; // Hide if online
        break;
      case BackendStatus.offline:
        color = Colors.red;
        text = "Backend Offline / Host Lookup Failed";
        break;
      case BackendStatus.noInternet:
        color = Colors.grey;
        text = "No Internet Connection";
        break;
    }

    if (!show) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
