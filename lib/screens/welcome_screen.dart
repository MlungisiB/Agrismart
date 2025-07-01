import 'package:agrismart/screens/signin_screen.dart';
import 'package:agrismart/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:agrismart/widgets/custom_scaffold.dart';
import 'package:agrismart/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center (
                 child: RichText(
                      textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Your Market Place\n',
                          style: TextStyle(
                            fontSize: 45.0,
                            fontWeight: FontWeight.w600,
                          )),
                        TextSpan(
                          text:
                              '\nSign In or Sign Up to continue',
                          style: TextStyle(
                            fontSize: 20,
                          )),
                      ],
                    ),
                 ),
              ),
            )),

          const Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign In ',
                      onTap: SignInScreen(),
                      color: Colors.transparent,
                      textColor: Colors.orange,
                    ),
                  ),

                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign Up ',
                      onTap: SignUpScreen(),
                      color: Colors.white,
                      textColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}