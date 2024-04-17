import 'package:flutter/material.dart';
import 'package:techknow/screens/home_screen.dart';
import 'package:techknow/utlis/colors.dart';
import 'package:techknow/widgets/button_widget.dart';
import 'package:techknow/widgets/text_widget.dart';
import 'package:techknow/widgets/textfield_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final id = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final confirmpassword = TextEditingController();

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
                height: 20,
              ),
              Image.asset(
                'assets/images/logo.png',
                width: 200,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                prefixIcon: Icons.person,
                width: 275,
                controller: name,
                label: 'Name',
              ),
              const SizedBox(
                height: 10,
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
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    prefixIcon: Icons.lock,
                    width: 275,
                    isObscure: true,
                    showEye: true,
                    controller: confirmpassword,
                    label: 'Confirm Password',
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              ButtonWidget(
                width: 275,
                label: 'Signup',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
