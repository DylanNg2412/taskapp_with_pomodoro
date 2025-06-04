import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tomato_task/data/model/task.dart';
import 'package:tomato_task/data/model/task_status.dart';
import 'package:tomato_task/data/repo/task_repo_supabase.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<Task> tasks = [];
  bool isLoading = true;
  int selectedDays = 7;
  final repo = TaskRepoSupabase();

  @override
  void initState() {
    super.initState();
    _getTasks();
  }

  Future<void> _getTasks() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final completedTasks = await repo.getCompletedTasksByUser(user.id);
    final inProgressTasks = await repo.getInProgressTasksByUser(user.id);

    setState(() {
      tasks = completedTasks + inProgressTasks;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _getTasks,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(),
                        const SizedBox(height: 20),
                        _timeSelectorForChart(),
                        const SizedBox(height: 20),
                        _showTaskChart(),
                        const SizedBox(height: 20),
                        _showTaskStats(),
                        const SizedBox(height: 20),
                        _showWeeklyTaskComparison(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Analytics',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track your productivity over time',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _timeSelectorForChart() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            [7, 14, 30].map((days) {
              final isSelected = selectedDays == days;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => selectedDays = days),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      '$days days',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _showTaskChart() {
    final chartData = _showChartForTasks();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks Completed',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.trending_up,
                color: const Color.fromARGB(255, 5, 184, 95),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: selectedDays > 14 ? 5 : 1,
                      getTitlesWidget: (value, meta) {
                        return _displayDateRange(value, chartData);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                minX: 0,
                maxX: (selectedDays - 1).toDouble(),
                minY: 0,
                maxY: _getMaxYAxisValue(chartData),
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        chartData.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.count.toDouble(),
                          );
                        }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 5, 184, 95),
                        const Color.fromARGB(
                          255,
                          5,
                          184,
                          95,
                        ).withValues(alpha: 0.8),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color.fromARGB(255, 5, 184, 95),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color.fromARGB(
                            255,
                            5,
                            184,
                            95,
                          ).withValues(alpha: 0.3),
                          const Color.fromARGB(
                            255,
                            5,
                            184,
                            95,
                          ).withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.blueAccent,
                    tooltipBorderRadius: BorderRadius.circular(8),
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final dayData = chartData[barSpot.x.toInt()];
                        return LineTooltipItem(
                          '${dayData.date.day}/${dayData.date.month}\n${dayData.count} tasks',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showTaskStats() {
    final completedToday = _getCompletedTasksForDay(DateTime.now());
    final totalCompleted =
        tasks.where((task) => task.status == TaskStatus.completed).length;
    final inProgressTotal = _getInProgressTasksForDay(DateTime.now());
    final avgPerDay =
        selectedDays > 0 ? (totalCompleted / selectedDays).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statusCard(
                  'Today',
                  completedToday.toString(),
                  Colors.blue,
                  Icons.today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statusCard(
                  'Total',
                  totalCompleted.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statusCard(
                  'In Progress',
                  inProgressTotal.toString(),
                  Colors.orange,
                  Icons.hourglass_empty,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statusCard(
                  'Avg/Day',
                  avgPerDay.toString(),
                  Colors.purple,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showWeeklyTaskComparison() {
    final thisWeekCount = _getTasksForWeek(0);
    final lastWeekCount = _getTasksForWeek(1);
    final percentChange =
        lastWeekCount > 0
            ? ((thisWeekCount - lastWeekCount) / lastWeekCount * 100).round()
            : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Comparison',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This Week', style: TextStyle(color: Colors.grey[600])),
                  Text(
                    '$thisWeekCount tasks',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last Week', style: TextStyle(color: Colors.grey[600])),
                  Text(
                    '$lastWeekCount tasks',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      percentChange >= 0
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      percentChange >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 16,
                      color: percentChange >= 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percentChange.abs()}%',
                      style: TextStyle(
                        color: percentChange >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<DayData> _showChartForTasks() {
    final now = DateTime.now();
    final dayDataList = <DayData>[];

    for (int i = selectedDays - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      dayDataList.add(DayData(date: date, count: 0));
    }

    final completedTasks =
        tasks
            .where(
              (task) =>
                  task.status == TaskStatus.completed &&
                  task.completedAt != null,
            )
            .toList();

    for (final task in completedTasks) {
      final completedDate = task.completedAt!;
      final completedDay = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );

      final dayIndex = dayDataList.indexWhere(
        (dayData) =>
            dayData.date.year == completedDay.year &&
            dayData.date.month == completedDay.month &&
            dayData.date.day == completedDay.day,
      );

      if (dayIndex != -1) {
        dayDataList[dayIndex] = DayData(
          date: dayDataList[dayIndex].date,
          count: dayDataList[dayIndex].count + 1,
        );
      }
    }

    return dayDataList;
  }

  Widget _displayDateRange(double value, List<DayData> chartData) {
    if (value.toInt() >= 0 && value.toInt() < chartData.length) {
      final date = chartData[value.toInt()].date;
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          selectedDays > 14 ? '${date.day}' : '${date.day}/${date.month}',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
        ),
      );
    }
    return const Text('');
  }

  double _getMaxYAxisValue(List<DayData> chartData) {
    if (chartData.isEmpty) return 5;
    final maxCount = chartData
        .map((value) => value.count)
        .reduce((a, b) => a > b ? a : b);
    return (maxCount + 2).toDouble();
  }

  int _getCompletedTasksForDay(DateTime day) {
    return tasks.where((task) {
      if (task.status != TaskStatus.completed || task.completedAt == null) {
        return false;
      }
      final completedDate = task.completedAt!;
      return completedDate.year == day.year &&
          completedDate.month == day.month &&
          completedDate.day == day.day;
    }).length;
  }

  int _getInProgressTasksForDay(DateTime day) {
    return tasks.where((task) {
      return task.status == TaskStatus.inProgress &&
          task.userId == Supabase.instance.client.auth.currentUser?.id;
    }).length;
  }

  int _getTasksForWeek(int pastWeeks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final startOfWeek = today.subtract(
      Duration(days: today.weekday - 1 + (pastWeeks * 7)),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return tasks.where((task) {
      if (task.status != TaskStatus.completed || task.completedAt == null) {
        return false;
      }

      final completedDate = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );

      return completedDate.isAtSameMomentAs(startOfWeek) ||
          (completedDate.isAfter(startOfWeek) &&
              completedDate.isBefore(endOfWeek.add(const Duration(days: 1))));
    }).length;
  }
}

class DayData {
  final DateTime date;
  final int count;

  DayData({required this.date, required this.count});
}
