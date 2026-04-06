import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'timeline_screen.dart';
import 'reports_screen.dart';
import 'more_screen.dart';
import 'add_record_screen.dart'; // We'll create this to add fuel/maintenance/etc.

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TimelineScreen(),
    const ReportsScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ekleme ekranını modal olarak veya yeni sayfa olarak aç.
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecordScreen()));
        },
        backgroundColor: const Color(0xFF38BDF8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Özet'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Zaman Ç.'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Raporlar'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Diğer'),
        ],
      ),
    );
  }
}
