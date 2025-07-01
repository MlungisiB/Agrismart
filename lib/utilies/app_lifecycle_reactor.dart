// utilies/app_lifecycle_reactor.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrismart/screens/home_page.dart';
import 'package:agrismart/screens/welcome_screen.dart';

class AppLifecycleReactor extends StatefulWidget {
  final Widget child;
  final GoTrueClient supabaseAuth;
  final GlobalKey<NavigatorState> navigatorKey; // Accept the global key

  const AppLifecycleReactor({
    super.key,
    required this.child,
    required this.supabaseAuth,
    required this.navigatorKey, // Require the global key
  });

  @override
  _AppLifecycleReactorState createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor> with WidgetsBindingObserver {
  DateTime? _lastPausedTime;
  final Duration _sessionTimeout = const Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSessionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
      debugPrint('App paused at: $_lastPausedTime');
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed.');
      _checkSessionStatus();
    }
  }

  // Changed method signature: no longer requires BuildContext
  Future<void> _checkSessionStatus() async {

    await Future.delayed(Duration.zero);

    // Get the NavigatorState from the global key
    final navigator = widget.navigatorKey.currentState;

    // Critical check: ensure the navigator is not null
    if (navigator == null) {
      debugPrint('Navigator state is null, cannot perform navigation.');
      return;
    }

    final currentSession = widget.supabaseAuth.currentSession;
    final isLoggedIn = currentSession != null;
    debugPrint('Is user logged in: $isLoggedIn');

    if (!isLoggedIn) {
      _navigateToWelcome(navigator); // Pass the navigator instance
      return;
    }

    if (_lastPausedTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastPausedTime!);
      debugPrint('Time spent in background: $difference');

      if (difference > _sessionTimeout) {
        debugPrint('Session expired, navigating to Welcome Screen.');
        _navigateToWelcome(navigator); // Pass the navigator instance
      } else {
        debugPrint('Session active, navigating to Home Page.');
        _navigateToHome(navigator); // Pass the navigator instance
      }
    } else {
      debugPrint('User logged in and app starting/resuming cold, navigating to Home Page.');
      _navigateToHome(navigator);
    }
    _lastPausedTime = null;
  }

  // All navigation methods now take NavigatorState
  void _navigateToWelcome(NavigatorState navigator) {
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen(), settings: const RouteSettings(name: '/welcome')),
          (Route<dynamic> route) => false,
    );
  }

  void _navigateToHome(NavigatorState navigator) {
    // Same consideration for this check as above.
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage(userEmail: '',), settings: const RouteSettings(name: '/home')),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}