import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  signIn(String text, String text2) {}

}
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Sign-in method
//   Future<User?> signIn(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return userCredential.user;
//     } catch (e) {
//       throw Exception("Error signing in: $e");
//     }
//   }

//   // Sign-out method
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }
