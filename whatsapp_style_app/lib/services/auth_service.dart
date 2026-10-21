import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = UserModel(
        uid: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        photoUrl: '',
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(user.uid).set(user.toMap());
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final doc = await _db.collection('users').doc(credential.user!.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
