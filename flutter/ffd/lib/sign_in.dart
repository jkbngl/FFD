import 'package:charts_flutter/flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'backup_color_change_on_nav_tab.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String name;
String email;
String imageUrl;
String token;

AuthCredential credential = null;

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  name = user.displayName;
  email = user.email;
  imageUrl = user.photoUrl;

  user.getIdToken(refresh: true).then((value) {
    token = value.token.toString();
    print(token);
  });

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();

  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
}

Future<String> signUp(String email, String password) async {
  AuthResult result = await _auth.createUserWithEmailAndPassword(
      email: email, password: password);
  FirebaseUser user = result.user;
  return user.uid;
}

Future<String> signIn(String email, String password) async {
  AuthResult result =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
  FirebaseUser user = result.user;
  return user.uid;
}

void getToken() async {
  AuthResult authResult = null;

  if (credential != null) {
    authResult = await _auth.signInWithCredential(credential);
  } else {
    authResult = await _auth.signInWithEmailAndPassword(
        email: 'jakob.engl@hotmail.de', password: 'test1234!');
  }

  final FirebaseUser user = authResult.user;

  name = user.displayName;
  email = user.email;
  imageUrl = user.photoUrl;

  user.getIdToken(refresh: true).then((value) {
    token = value.token.toString();
    print(token);

    return token;
  });
}

void signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Sign Out");
}
