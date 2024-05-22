import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techknow/services/add_module.dart';
import 'package:techknow/utlis/colors.dart';
import 'package:techknow/widgets/text_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:techknow/widgets/toast_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StudentsPage extends StatefulWidget {
  String id;

  StudentsPage({
    super.key,
    required this.id,
  });

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  late bool pickedFile = false;

  late String fileName = '';

  late String fileUrl = '';

  late File imageFile;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          title: TextWidget(
            text: 'Students',
            fontSize: 18,
            color: Colors.white,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const TabBar(tabs: [
              Tab(
                text: 'Pending',
              ),
              Tab(
                text: 'All',
              ),
            ]),
            Expanded(
              child: TabBarView(
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Requests')
                          .where('code', isEqualTo: widget.id)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return const Center(child: Text('Error'));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Center(
                                child: CircularProgressIndicator(
                              color: Colors.black,
                            )),
                          );
                        }

                        final data = snapshot.requireData;
                        return GridView.builder(
                          itemCount: data.docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Accept Confirmation',
                                            style: TextStyle(
                                                fontFamily: 'QBold',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: const Text(
                                            'Are you sure you want to accept this student to the class?',
                                            style: TextStyle(
                                                fontFamily: 'QRegular'),
                                          ),
                                          actions: <Widget>[
                                            MaterialButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text(
                                                'Close',
                                                style: TextStyle(
                                                    fontFamily: 'QRegular',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            MaterialButton(
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection('Classes')
                                                    .doc(widget.id)
                                                    .update({
                                                  'students':
                                                      FieldValue.arrayUnion([
                                                    data.docs[index]['uid']
                                                  ]),
                                                });
                                                await FirebaseFirestore.instance
                                                    .collection('Requests')
                                                    .doc(data.docs[index].id)
                                                    .delete();
                                                // Delete pending document
                                                // Add student id to the class
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Continue',
                                                style: TextStyle(
                                                    fontFamily: 'QRegular',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ));
                              },
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_circle_outlined,
                                      size: 75,
                                      color: primary,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TextWidget(
                                      text: 'Pending',
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontFamily: 'Medium',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                  StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Classes')
                          .doc(widget.id)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: Text('Loading'));
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Something went wrong'));
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        dynamic data = snapshot.data;
                        return GridView.builder(
                          itemCount: data['students'].length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            return StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(data['students'][index])
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: Text('Loading'));
                                  } else if (snapshot.hasError) {
                                    return const Center(
                                        child: Text('Something went wrong'));
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  dynamic studentData = snapshot.data;

                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Remove Confirmation',
                                                  style: TextStyle(
                                                      fontFamily: 'QBold',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to remove this student to the class?',
                                                  style: TextStyle(
                                                      fontFamily: 'QRegular'),
                                                ),
                                                actions: <Widget>[
                                                  MaterialButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    child: const Text(
                                                      'Close',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'QRegular',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  MaterialButton(
                                                    onPressed: () async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('Classes')
                                                          .doc(widget.id)
                                                          .update({
                                                        'students': FieldValue
                                                            .arrayRemove([
                                                          data['students']
                                                              [index]
                                                        ]),
                                                      });

                                                      // Delete pending document
                                                      // Add student id to the class
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text(
                                                      'Continue',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'QRegular',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ));
                                    },
                                    child: Card(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.account_circle_outlined,
                                            size: 75,
                                            color: primary,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextWidget(
                                            text: studentData['name'],
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontFamily: 'Medium',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
