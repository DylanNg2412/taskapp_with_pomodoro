import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskapp_with_pomodoro/navigation/navigation.dart';
import 'package:taskapp_with_pomodoro/ui/chart/chart_screen.dart';
import 'package:taskapp_with_pomodoro/ui/home/home_screen.dart';
import 'package:taskapp_with_pomodoro/ui/pomodoro/pomodoro_screen.dart';

class TabContainer extends StatefulWidget {
  const TabContainer({super.key});

  @override
  State<TabContainer> createState() => _TabContainerState();
}

class _TabContainerState extends State<TabContainer> {
  Widget _tabBarItem(String title, IconData icon) {
    return SizedBox(
      height: 50,
      child: Column(children: [Icon(icon), Text(title)]),
    );
  }

  void _navigateToPomodoro() {
    context.pushNamed(Screen.pomodoro.name);
  }

  void _navigateToChart() {
    context.pushNamed(Screen.chart.name);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: const TabBarView(children: [HomeScreen(), PomodoroScreen(), ChartScreen()]),
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
