import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addRequest(code) async {
  final docUser = FirebaseFirestore.instance.collection('Requests').doc();

  final json = {
    'id': docUser.id,
    'code': code,
    'dateTime': DateTime.now(),
    'uid': FirebaseAuth.instance.currentUser!.uid
  };

  await docUser.set(json);
}
