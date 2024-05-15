import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addModule(file, code) async {
  final docUser = FirebaseFirestore.instance.collection('Modules').doc();

  final json = {
    'file': file,
    'id': docUser.id,
    'code': code,
    'status': 'Unlocked',
    'dateTime': DateTime.now(),
    'uid': FirebaseAuth.instance.currentUser!.uid
  };

  await docUser.set(json);
}
