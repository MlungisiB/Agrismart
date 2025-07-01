import 'package:agrismart/screens/home_page.dart';
import 'package:agrismart/screens/welcome_screen.dart';
import 'package:agrismart/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:agrismart/screens/cart_manager.dart';

import 'const.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: '',
    anonKey: '',
  );
  Stripe.publishableKey = stripePublishableKey;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => CartManager()),
        ],
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Agrismart',
        theme: lightMode,
        initialRoute: '/signup', // Start at the signup screen
        routes: {
          '/signup': (context) => const WelcomeScreen(),
          '/home': (context) => const HomePage(userEmail: '',),
        }
    ));
  }
}
