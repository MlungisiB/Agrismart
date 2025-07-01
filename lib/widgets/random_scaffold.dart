import 'package:flutter/material.dart';

class RandomScaffold extends StatelessWidget {
  const RandomScaffold({super.key, this.child });
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.green),
        backgroundColor: Colors.transparent,

      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
         /* Image.asset('assets/images/bg3.jpg' ,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ), */

          SafeArea(
            child: child!,
          ),
        ],
      ),
    );
  }
}