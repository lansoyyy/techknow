import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techknow/services/add_module.dart';
import 'package:techknow/services/add_quiz.dart';
import 'package:techknow/utlis/colors.dart';
import 'package:techknow/widgets/text_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:techknow/widgets/textfield_widget.dart';
import 'package:techknow/widgets/toast_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class QuizPage extends StatefulWidget {
  String id;
  bool isteacher;

  QuizPage({super.key, required this.id, required this.isteacher});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  late bool pickedFile = false;

  late String fileName = '';

  late String fileUrl = '';

  late File imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.isteacher
          ? FloatingActionButton(
              backgroundColor: primary,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                addModuleDialog();
              },
            )
          : null,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: TextWidget(
          text: 'Quizzes',
          fontSize: 18,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Quizzes')
              .where('code', isEqualTo: widget.id)
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
            return GridView.builder(
              itemCount: data.docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (widget.isteacher) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                            height: 150,
                            child: Column(
                              children: [
                                data.docs[index]['status'] == 'Unlocked'
                                    ? ListTile(
                                        onTap: () async {
                                          await FirebaseFirestore.instance
                                              .collection('Quizzes')
                                              .doc(data.docs[index].id)
                                              .update({'status': 'Locked'});
                                          Navigator.pop(context);
                                        },
                                        leading: const Icon(
                                          Icons.lock,
                                        ),
                                        trailing: TextWidget(
                                          text: 'Lock quiz',
                                          fontSize: 18,
                                        ),
                                      )
                                    : ListTile(
                                        onTap: () async {
                                          await FirebaseFirestore.instance
                                              .collection('Quizzes')
                                              .doc(data.docs[index].id)
                                              .update({'status': 'Unlocked'});
                                          Navigator.pop(context);
                                        },
                                        leading: const Icon(
                                          Icons.lock_open_outlined,
                                        ),
                                        trailing: TextWidget(
                                          text: 'Unlock quiz',
                                          fontSize: 18,
                                        ),
                                      ),
                                ListTile(
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('Quizzes')
                                        .doc(data.docs[index].id)
                                        .delete();
                                    Navigator.pop(context);
                                  },
                                  leading: const Icon(
                                    Icons.delete_outline,
                                  ),
                                  trailing: TextWidget(
                                    text: 'Delete quiz',
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 75,
                          color: primary,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            if (data.docs[index]['status'] == 'Unlocked') {
                              await launchUrlString(data.docs[index]['file']);
                            } else {
                              showToast('Cannot open locked quiz!');
                            }
                          },
                          icon: const Icon(
                            Icons.link,
                            color: Colors.green,
                          ),
                          label: TextWidget(
                            text: 'Open quiz',
                            fontSize: 14,
                            color: Colors.green,
                            fontFamily: 'Bold',
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextWidget(
                          text: data.docs[index]['status'],
                          fontSize: 12,
                          color: data.docs[index]['status'] == 'Unlocked'
                              ? Colors.green
                              : Colors.red,
                          fontFamily: 'Medium',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  final link = TextEditingController();

  addModuleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFieldWidget(
                  controller: link,
                  label: 'Quiz Link',
                ),
              ],
            );
          }),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (link.text == '') {
                  showToast('Please add a quiz link!');
                  Navigator.of(context).pop();
                } else {
                  addQuiz(link.text, widget.id);

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
