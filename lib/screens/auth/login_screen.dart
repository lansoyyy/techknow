import 'package:flutter/material.dart';
import 'package:techknow/screens/auth/signup_screen.dart';
import 'package:techknow/screens/home_screen.dart';
import 'package:techknow/utlis/colors.dart';
import 'package:techknow/widgets/button_widget.dart';
import 'package:techknow/widgets/text_widget.dart';
import 'package:techknow/widgets/textfield_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final id = TextEditingController();
  final password = TextEditingController();

  bool isstudent = true;
  bool isteacher = false;
  bool remembered = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              Image.asset(
                'assets/images/logo.png',
                width: 200,
              ),
              const SizedBox(
                height: 50,
              ),
              TextFieldWidget(
                prefixIcon: Icons.email,
                width: 275,
                controller: id,
                label: 'Email',
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  TextFieldWidget(
                    prefixIcon: Icons.lock,
                    width: 275,
                    isObscure: true,
                    showEye: true,
                    controller: password,
                    label: 'Password',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 40, left: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              activeColor: primary,
                              value: remembered,
                              onChanged: (value) {
                                setState(() {
                                  remembered = value!;
                                });
                              },
                            ),
                            TextWidget(
                              text: 'Remember Me',
                              fontSize: 12,
                              color: primary,
                              fontFamily: 'Bold',
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: TextWidget(
                            text: 'Forgot Password?',
                            fontSize: 12,
                            color: primary,
                            fontFamily: 'Bold',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              ButtonWidget(
                width: 275,
                label: 'Login',
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const HomeScreen()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    text: "Don't have an account?",
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SignupScreen()));
                    },
                    child: TextWidget(
                      text: "Create now",
                      fontSize: 12,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
