import 'package:vita_flow/screens/Rider/task_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class RiderNavBar extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const RiderNavBar({super.key, required this.currentUser});

  @override
  State<RiderNavBar> createState() => _DonorNavBarState();
}

class _DonorNavBarState extends State<RiderNavBar> {
  int selectedIndex = 0;

  // KEYS FOR NESTED NAVIGATORS
  final homeNavKey = GlobalKey<NavigatorState>();
  final requestsNavKey = GlobalKey<NavigatorState>();
  final historyNavKey = GlobalKey<NavigatorState>();
  final profileNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Give Back button functionality inside nested navigators
        final currentNavigator = [
          homeNavKey,
          requestsNavKey,
          historyNavKey,
          profileNavKey,
        ][selectedIndex].currentState;

        if (currentNavigator!.canPop()) {
          currentNavigator.pop();
          return false;
        }
        return true;
      },

      child: Scaffold(
        // MAIN BODY (IndexedStack keeps screens alive)
        body: IndexedStack(
          index: selectedIndex,
          children: [
            _buildNavigator(homeNavKey, RiderHomeScreen(currentUser: widget.currentUser)),
            _buildNavigator(requestsNavKey, const RiderTasksScreen()),
            _buildNavigator(historyNavKey, const RiderHistoryScreen()),
            _buildNavigator(profileNavKey, const RiderProfileScreen()),
          ],
        ),

        // BOTTOM NAV BAR
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          selectedItemColor: const Color(0xFFE0463A),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,

          onTap: (i) {
            if (i == 0) {
              // ❗ Whenever HOME is tapped → reset home navigation stack
              homeNavKey.currentState?.popUntil((route) => route.isFirst);
            }

            setState(() {
              selectedIndex = i;
            });
          },

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Requests"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  // BUILDS EACH TAB'S NESTED NAVIGATOR
  Widget _buildNavigator(GlobalKey<NavigatorState> key, Widget screen) {
    return Navigator(
      key: key,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => screen);
      },
    );
  }
}
