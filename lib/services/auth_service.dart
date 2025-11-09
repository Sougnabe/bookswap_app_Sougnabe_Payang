import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookswap_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<AppUser?> get user {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      return AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
        isEmailVerified: firebaseUser.emailVerified,
        createdAt: firebaseUser.metadata.creationTime,
      );
    });
  }

  Future<AppUser?> signUpWithEmail(String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await result.user!.updateDisplayName(displayName);
      await result.user!.sendEmailVerification();
      
      return AppUser(
        id: result.user!.uid,
        email: result.user!.email!,
        displayName: displayName,
        isEmailVerified: false,
        createdAt: result.user!.metadata.creationTime,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: e.toString(),
      );
    }
  }

  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (!result.user!.emailVerified) {
        await signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before signing in.',
        );
      }
      
      return AppUser(
        id: result.user!.uid,
        email: result.user!.email!,
        displayName: result.user!.displayName ?? result.user!.email!.split('@')[0],
        isEmailVerified: result.user!.emailVerified,
        createdAt: result.user!.metadata.creationTime,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}