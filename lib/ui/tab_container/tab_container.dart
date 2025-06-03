import 'package:flutter/material.dart';
import 'package:tomato_task/ui/chart/chart_screen.dart';
import 'package:tomato_task/ui/home/home_screen.dart';
import 'package:tomato_task/ui/pomodoro/pomodoro_screen.dart';

class TabContainer extends StatefulWidget {
  const TabContainer({super.key});

  @override
  State<TabContainer> createState() => _TabContainerState();
}

class _TabContainerState extends State<TabContainer> {
  Widget _tabBarItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SizedBox(
        height: 55,
        child: Column(children: [Icon(icon), Text(title)]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: const TabBarView(
          children: [HomeScreen(), PomodoroScreen(), ChartScreen()],
        ),
        bottomNavigationBar: TabBar(
          indicatorColor: Colors.transparent,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: [
            _tabBarItem("Home", Icons.home),
            _tabBarItem("Pomodoro", Icons.timer),
            _tabBarItem("Chart", Icons.bar_chart),
          ],
        ),
      ),
    );
  }
}
