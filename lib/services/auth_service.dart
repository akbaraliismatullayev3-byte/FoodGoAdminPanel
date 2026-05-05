
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        return await getUserModel(user.uid);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserModel(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
    } else {
      // If user doc doesn't exist, create it as 'user' role
      UserModel newUser = UserModel(
        uid: uid, 
        email: _auth.currentUser?.email ?? '', 
        name: _auth.currentUser?.displayName ?? 'New User',
        role: 'user'
      );
      await _db.collection('users').doc(uid).set(newUser.toMap());
      return newUser;
    }
  }

  Future<bool> isAdmin(String uid) async {
    UserModel? user = await getUserModel(uid);
    return user?.isAdmin ?? false;
  }
}
