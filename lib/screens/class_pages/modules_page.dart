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

class ModulesPage extends StatefulWidget {
  String id;
  bool isteacher;

  ModulesPage({super.key, required this.id, required this.isteacher});

  @override
  State<ModulesPage> createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
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
          text: 'Modules',
          fontSize: 18,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Modules')
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
                                              .collection('Modules')
                                              .doc(data.docs[index].id)
                                              .update({'status': 'Locked'});
                                          Navigator.pop(context);
                                        },
                                        leading: const Icon(
                                          Icons.lock,
                                        ),
                                        trailing: TextWidget(
                                          text: 'Lock module',
                                          fontSize: 18,
                                        ),
                                      )
                                    : ListTile(
                                        onTap: () async {
                                          await FirebaseFirestore.instance
                                              .collection('Modules')
                                              .doc(data.docs[index].id)
                                              .update({'status': 'Unlocked'});
                                          Navigator.pop(context);
                                        },
                                        leading: const Icon(
                                          Icons.lock_open_outlined,
                                        ),
                                        trailing: TextWidget(
                                          text: 'Unlock module',
                                          fontSize: 18,
                                        ),
                                      ),
                                ListTile(
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('Modules')
                                        .doc(data.docs[index].id)
                                        .delete();
                                    Navigator.pop(context);
                                  },
                                  leading: const Icon(
                                    Icons.delete_outline,
                                  ),
                                  trailing: TextWidget(
                                    text: 'Delete module',
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
                          Icons.file_copy_outlined,
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
                              showToast('Cannot open locked module!');
                            }
                          },
                          icon: const Icon(
                            Icons.download,
                            color: Colors.green,
                          ),
                          label: TextWidget(
                            text: 'Open module',
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

  addModuleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                pickedFile
                    ? ListTile(
                        leading: const Icon(Icons.attach_file),
                        title: TextWidget(
                            text: fileName, fontSize: 14, color: Colors.black),
                        trailing: IconButton(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                              allowMultiple: false,
                              onFileLoading: (p0) {
                                return const CircularProgressIndicator();
                              },
                            )
                                .then((value) {
                              setState(
                                () {
                                  pickedFile = true;
                                  fileName = value!.names[0]!;
                                  imageFile = File(value.paths[0]!);
                                },
                              );
                              return null;
                            });

                            await firebase_storage.FirebaseStorage.instance
                                .ref('Files/$fileName')
                                .putFile(imageFile);
                            fileUrl = await firebase_storage
                                .FirebaseStorage.instance
                                .ref('Files/$fileName')
                                .getDownloadURL();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.upload_file_outlined,
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                            allowMultiple: false,
                            onFileLoading: (p0) {
                              return const CircularProgressIndicator();
                            },
                          )
                              .then((value) {
                            setState(
                              () {
                                pickedFile = true;
                                fileName = value!.names[0]!;
                                imageFile = File(value.paths[0]!);
                              },
                            );
                            return null;
                          });

                          await firebase_storage.FirebaseStorage.instance
                              .ref('Files/$fileName')
                              .putFile(imageFile);
                          fileUrl = await firebase_storage
                              .FirebaseStorage.instance
                              .ref('Files/$fileName')
                              .getDownloadURL();
                          setState(() {});
                        },
                        child: TextWidget(
                            text: 'Attach a file',
                            fontSize: 12,
                            color: Colors.grey),
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
                if (fileUrl == '') {
                  showToast('Please upload a file!');
                  Navigator.of(context).pop();
                } else {
                  addModule(fileUrl, widget.id);

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
