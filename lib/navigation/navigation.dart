import 'package:go_router/go_router.dart';
import 'package:taskapp_with_pomodoro/ui/add_task/add_task_screen.dart';
import 'package:taskapp_with_pomodoro/ui/chart/chart_screen.dart';
import 'package:taskapp_with_pomodoro/ui/edit_task/edit_task_screen.dart';
import 'package:taskapp_with_pomodoro/ui/home/home_screen.dart';
import 'package:taskapp_with_pomodoro/ui/login/login_screen.dart';
import 'package:taskapp_with_pomodoro/ui/pomodoro/pomodoro_screen.dart';
import 'package:taskapp_with_pomodoro/ui/sign_up/sign_up_screen.dart';
import 'package:taskapp_with_pomodoro/ui/tab_container/tab_container.dart';

class Navigation {
  static const initial = "/login";
  static final routes = [
    GoRoute(
      path: "/",
      name: Screen.home.name,
      builder: (context, state) => const TabContainer()
    ),
    GoRoute(
      path: "/pomodoro",
      name: Screen.pomodoro.name,
      builder: (context, state) => const PomodoroScreen()
    ),
    GoRoute(
      path: "/chart",
      name: Screen.chart.name,
      builder: (context, state) => const ChartScreen()
    ),
    GoRoute(
      path: "/login",
      name: Screen.login.name,
      builder: (context, state) => const LoginScreen()
    ),
    GoRoute(
      path: "/addTask",
      name: Screen.addTask.name,
      builder: (context, state) => const AddTaskScreen()
    ),
    GoRoute(
      path: "/editTask/:id",
      name: Screen.editTask.name,
      builder: (context, state) => EditTaskScreen(
        id: state.pathParameters["id"]!,
      )
    ),
    GoRoute(
      path: "/signUp",
      name: Screen.signUp.name,
      builder: (context, state) => const SignUpScreen(),
    ),
  ];
}

enum Screen { home, pomodoro, chart, addTask, editTask, login, signUp }