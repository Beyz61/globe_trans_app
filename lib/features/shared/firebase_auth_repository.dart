// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  @override
  void setVerificationId(String? verificationId) {
    _verificationId = verificationId;
  }

  // Authentifizierung: verifyPhoneNumber -> wenn sent sms completed
  // -> verificationId zwischenspeichern -> user gibt sms code ein -> signInWithCreditional

  // Anmelden mit Google Account
  @override
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on Exception catch (e) {
      print('exception->$e');
    }
  }

  // Sign Out von Google Account
  @override
  Future<void> signOutFromGoogle() async {
    print("Signing out");
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // SMS Code senden für Mobile Nummer Verifizierung
  @override
  Future<void> sendVerificationCode(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        _auth.signInWithCredential(credential);
        setVerificationId(null);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
        throw Exception(
            "Fehler bei der Verifizierung:  ${e.code} ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setVerificationId(verificationId);
        print("Code gesendet: $verificationId");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Auto-Retrieval Timeout: $verificationId");
      },
    );
  }

  // Anmelden mit Mobile Nummer
  @override
  Future<void> signInWithPhoneNumber(String smsCode) async {
    if (_verificationId == null) throw Exception("Verification Id is null");
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }
}
