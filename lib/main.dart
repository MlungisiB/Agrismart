import 'package:agrismart/screens/home_page.dart';
import 'package:agrismart/screens/welcome_screen.dart';
import 'package:agrismart/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:agrismart/screens/cart_manager.dart';
import 'package:flutter/foundation.dart';

import 'const.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hqsttrggzulpizedagku.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3R0cmdnenVscGl6ZWRhZ2t1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMxMTIyMzMsImV4cCI6MjA1ODY4ODIzM30.ety5LFcbFZBZD1c0zgYkSgXUZ_l9cUIF7hBwhY5TrmI',
  );
  if (!kIsWeb) {
    Stripe.publishableKey = stripePublishableKey;
  } else{

  }
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
