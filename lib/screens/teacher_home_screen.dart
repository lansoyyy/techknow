import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techknow/screens/auth/login_screen.dart';
import 'package:techknow/screens/class_pages/modules_page.dart';
import 'package:techknow/screens/class_pages/quiz_page.dart';
import 'package:techknow/services/add_class.dart';
import 'package:techknow/widgets/button_widget.dart';
import 'package:techknow/widgets/textfield_widget.dart';
import 'package:techknow/widgets/toast_widget.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  bool inclasses = false;

  String generateRandomString(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Classes')
              .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(child: Text('Error'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.black,
                )),
              );
            }

            final data = snapshot.requireData;
            return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        'assets/images/back.jpg',
                      ),
                      fit: BoxFit.cover),
                ),
                child: Stack(
                  children: [
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text(
                                        'Logout Confirmation',
                                        style: TextStyle(
                                            fontFamily: 'QBold',
                                            fontWeight: FontWeight.bold),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to Logout?',
                                        style:
                                            TextStyle(fontFamily: 'QRegular'),
                                      ),
                                      actions: <Widget>[
                                        MaterialButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text(
                                            'Close',
                                            style: TextStyle(
                                                fontFamily: 'QRegular',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: () async {
                                            Navigator.of(context).pushReplacement(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen()));
                                          },
                                          child: const Text(
                                            'Continue',
                                            style: TextStyle(
                                                fontFamily: 'QRegular',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ));
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          height: inclasses ? 400 : 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: inclasses
                                ? classes(data.docs.first['code'])
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      data.docs.isEmpty
                                          ? ButtonWidget(
                                              label: 'Create Class',
                                              onPressed: () {
                                                setState(() {
                                                  code.text =
                                                      generateRandomString(6);
                                                });
                                                addClassDialog();
                                              },
                                            )
                                          : ButtonWidget(
                                              label:
                                                  'Class (${data.docs.first['code']})',
                                              onPressed: () {
                                                setState(() {
                                                  inclasses = true;
                                                });
                                              },
                                            ),
                                      ButtonWidget(
                                        label: 'Profile',
                                        onPressed: () {},
                                      ),
                                      ButtonWidget(
                                        label: 'Settings',
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
          }),
    );
  }

  Widget classes(String code) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ButtonWidget(
          label: 'Leaderboards',
          onPressed: () {},
        ),
        ButtonWidget(
          label: 'Modules',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ModulesPage(
                      isteacher: true,
                      id: code,
                    )));
          },
        ),
        ButtonWidget(
          label: 'Quizzes',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => QuizPage(
                      isteacher: true,
                      id: code,
                    )));
          },
        ),
        ButtonWidget(
          label: 'Announcements',
          onPressed: () {},
        ),
        ButtonWidget(
          label: 'Student Records',
          onPressed: () {},
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonWidget(
              color: Colors.red,
              label: 'Back',
              onPressed: () {
                setState(() {
                  inclasses = false;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  final name = TextEditingController();
  final code = TextEditingController();
  addClassDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFieldWidget(
                  isEnabled: false,
                  controller: code,
                  label: 'Class Code',
                ),
                TextFieldWidget(
                  controller: name,
                  label: 'Class Name',
                ),
                const SizedBox(
                  height: 20,
                ),
                ButtonWidget(
                  label: 'Add Class',
                  onPressed: () {
                    addClass(name.text, code.text);
                    showToast('Class added!');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
