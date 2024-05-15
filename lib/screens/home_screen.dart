import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techknow/screens/class_pages/modules_page.dart';
import 'package:techknow/services/add_class.dart';
import 'package:techknow/widgets/button_widget.dart';
import 'package:techknow/widgets/textfield_widget.dart';
import 'package:techknow/widgets/toast_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool inclasses = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Classes')
              .where('students',
                  arrayContains: FirebaseAuth.instance.currentUser!.uid)
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 250,
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
                                          label: 'Join Class',
                                          onPressed: () {
                                            joinClassDialog();
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
                ));
          }),
    );
  }

  Widget classes(String code) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ButtonWidget(
          label: 'Modules',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ModulesPage(
                      isteacher: false,
                      id: code,
                    )));
          },
        ),
        ButtonWidget(
          label: 'Quizzes',
          onPressed: () {},
        ),
        ButtonWidget(
          label: 'Announcements',
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

  final code = TextEditingController();
  joinClassDialog() {
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
                  controller: code,
                  label: 'Class Code',
                ),
                const SizedBox(
                  height: 20,
                ),
                ButtonWidget(
                  label: 'Join Class',
                  onPressed: () async {
                    DocumentSnapshot doc = await FirebaseFirestore.instance
                        .collection('Classes')
                        .doc(code.text)
                        .get();

                    if (doc.exists) {
                      await FirebaseFirestore.instance
                          .collection('Classes')
                          .doc(code.text)
                          .update({
                        'students': FieldValue.arrayUnion(
                            [FirebaseAuth.instance.currentUser!.uid]),
                      });
                      showToast('Class joined!');
                      Navigator.pop(context);
                    } else {
                      showToast('Class do not exist!');
                      Navigator.pop(context);
                    }

                    code.clear();
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
