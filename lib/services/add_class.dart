import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addClass(name, code) async {
  final docUser = FirebaseFirestore.instance.collection('Classes').doc(code);

  final json = {
    'name': name,
    'students': [],
    'id': docUser.id,
    'code': code,
    'dateTime': DateTime.now(),
    'uid': FirebaseAuth.instance.currentUser!.uid
  };

  await docUser.set(json);
}
