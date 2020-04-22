import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String name;
String email;
String imageUrl;
String token;

String emailPasswordLoginEmail;
String emailPasswordLoginPassword;

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

    return 'SUCCESS'; // Must be called exactly SUCCESS do not change, is used for validating
  });

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();

  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
}

Future<String> signUp(String email, String password) async {

  final prefs = await SharedPreferences.getInstance();
  prefs.setString('mail', email);
  prefs.setString('password', password);


  // Store them in a variable so they can be used by get token
  emailPasswordLoginEmail = email;
  emailPasswordLoginPassword = password;

  try {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;

    name =
        user.displayName != null ? user.displayName : user.email.split('@')[0];
    email = user.email != null ? user.email : emailPasswordLoginEmail;
    imageUrl = user.photoUrl != null
        ? user.photoUrl
        : 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Microsoft_Account.svg/512px-Microsoft_Account.svg.png';

    user.getIdToken(refresh: true).then((value) {
      token = value.token.toString();
      return token;
    });

    return 'SUCCESS'; // Must be called exactly SUCCESS do not change, is used for validating
  } catch (e) {
    return e.code;
  }
}

Future<String> signIn(String email, String password) async {
  // Store them in a variable so they can be used by get token
  emailPasswordLoginEmail = email;
  emailPasswordLoginPassword = password;

  final prefs = await SharedPreferences.getInstance();
  prefs.setString('mail', email);

  try {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;

    name =
        user.displayName != null ? user.displayName : user.email.split('@')[0];
    email = user.email != null ? user.email : emailPasswordLoginEmail;
    imageUrl = user.photoUrl != null
        ? user.photoUrl
        : 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Microsoft_Account.svg/512px-Microsoft_Account.svg.png';

    user.getIdToken(refresh: true).then((value) {
      token = value.token.toString();
      return token;
    });

    return 'SUCCESS'; // Must be called exactly SUCCESS do not change, is used for validating
  } catch (e) {
    return e.code;
  }
}

getToken() async {
  AuthResult authResult = null;

  if (credential != null) {
    authResult = await _auth.signInWithCredential(credential);
  } else {
    authResult = await _auth.signInWithEmailAndPassword(
        email: emailPasswordLoginEmail, password: emailPasswordLoginPassword);
  }

  final FirebaseUser user = authResult.user;

  name = user.displayName != null ? user.displayName : user.email.split('@')[0];
  email = user.email != null ? user.email : emailPasswordLoginEmail;
  imageUrl = user.photoUrl != null
      ? user.photoUrl
      : 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Microsoft_Account.svg/512px-Microsoft_Account.svg.png';

  user.getIdToken(refresh: true).then((value) {
    token = value.token.toString();
    return token;
  });
}

void signOut() async {
  await _auth.signOut();
  await googleSignIn.signOut();

  credential = null;

  print("User Sign Out");
}
