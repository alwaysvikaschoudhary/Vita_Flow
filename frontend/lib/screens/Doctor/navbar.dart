import 'package:vita_flow/screens/Doctor/Request_screen.dart';
import 'package:vita_flow/screens/Doctor/home_screen.dart';
import 'package:vita_flow/screens/Doctor/history_screen.dart';
import 'package:vita_flow/screens/Doctor/profile_screen.dart';
import 'package:flutter/material.dart';

class DoctorNavBar extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const DoctorNavBar({super.key, required this.currentUser});

  @override
  State<DoctorNavBar> createState() => _DoctorNavBarState();
}

class _DoctorNavBarState extends State<DoctorNavBar> {
  int selectedIndex = 0;

  final homeKey = GlobalKey<NavigatorState>();
  final requestKey = GlobalKey<NavigatorState>();
  final historyKey = GlobalKey<NavigatorState>();
  final profileKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _buildNav(homeKey, DoctorHomeScreen(currentUser: widget.currentUser)),
          _buildNav(requestKey, const DoctorRequestsScreen()),
          _buildNav(historyKey, const DoctorHistoryScreen()),
          _buildNav(profileKey, DoctorProfileScreen(currentUser: widget.currentUser)),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildNav(GlobalKey<NavigatorState> key, Widget child) {
    return Navigator(
      key: key,
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => child),
    );
  }
}
