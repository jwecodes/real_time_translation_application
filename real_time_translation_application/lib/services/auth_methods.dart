import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_time_translation_application/models/user.dart' as AppUserModel; // Alias to avoid conflict

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up Method
  Future<String?> signUp(
      String email, String password, AppUserModel.User user) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      return null; // If no errors, return null (success)
    } on FirebaseAuthException catch (e) {
      return e.message; // Return Firebase error message
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // Login Method
  Future<String?> login(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await FirebaseAuth.instance.signOut(); // optional: force logout
        return "Please verify your email before logging in.";
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred.";
    }
  }


  // Logout Method
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An error occurred while sending reset email.";
    }
  }
}
