import 'package:flutter/material.dart';
import 'backup_color_change_on_nav_tab.dart';
import 'sign_in.dart';
import 'package:http/http.dart' as http;
import 'app_localizations.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextFieldController = TextEditingController();
  final passwordTextFieldController = TextEditingController();

  @override
  void initState() {

    emailTextFieldController.text = 'jakob.engl@gknpm.com';
    passwordTextFieldController.text = 'test123456789';

    // 161
    /*signInWithGoogle().whenComplete(() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return MyHomePage();
          },
        ),
      );
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: LayoutBuilder(
              builder: (context, constraint) {
                return SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraint.maxHeight),
                        child: IntrinsicHeight(
                          child: Stack(children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          child: Image(
                                            image: AssetImage(
                                                "assets/register_ffd.png"),
                                            height: 100.0,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 30.0,
                                              top: 0,
                                              right: 30,
                                              bottom: 0),
                                          //color: Colors.blue[600],
                                          alignment: Alignment.center,
                                          //child: Text('Submit'),
                                          child: TextFormField(
                                            style: TextStyle(height: 2),
                                            controller:
                                                emailTextFieldController,
                                            decoration: InputDecoration(
                                                // hintText: 'Enter ur amount',
                                                //hintStyle: TextStyle(height: 1.75),
                                                labelText:
                                                    AppLocalizations.of(context)
                                                        .translate('email'),
                                                labelStyle: TextStyle(
                                                    height: 0.5,
                                                    color: Color(0xff003680)),
                                                //increases the height of cursor
                                                icon: Icon(
                                                  Icons.mail,
                                                  color: Color(0xff003680),
                                                ),
                                                //prefixIcon: Icon(Icons.attach_money),
                                                //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                                enabledBorder:
                                                    new UnderlineInputBorder(
                                                        borderSide: new BorderSide(
                                                            color: Color(
                                                                0xff003680)))),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 30.0,
                                              top: 0,
                                              right: 30,
                                              bottom: 0),
                                          //color: Colors.blue[600],
                                          alignment: Alignment.center,
                                          //child: Text('Submit'),
                                          child: TextFormField(
                                            //keyboard with numbers only will appear to the screen
                                            style: TextStyle(height: 2),
                                            //increases the height of cursor
                                            //autofocus: true,
                                            obscureText: true,
                                            controller:
                                                passwordTextFieldController,
                                            decoration: InputDecoration(
                                                // hintText: 'Enter ur amount',
                                                //hintStyle: TextStyle(height: 1.75),
                                                labelText:
                                                    AppLocalizations.of(context)
                                                        .translate('password'),
                                                labelStyle: TextStyle(
                                                    height: 0.5,
                                                    color: Color(0xff003680)),
                                                //increases the height of cursor
                                                icon: Icon(
                                                  Icons.security,
                                                  color: Color(0xff003680),
                                                ),
                                                //prefixIcon: Icon(Icons.attach_money),
                                                //labelStyle: TextStyle(color: Color(0xff0957FF)),
                                                enabledBorder:
                                                    new UnderlineInputBorder(
                                                        borderSide: new BorderSide(
                                                            color: Color(
                                                                0xff003680)))),
                                          ),
                                        ),
                                        SizedBox(height: 50),
                                        _signInButton(),
                                        SizedBox(height: 10),
                                        _registerButton(),
                                        SizedBox(height: 10),
                                        _loginButton(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ]),
                        )));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        signInWithGoogle().whenComplete(() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return MyHomePage();
              },
            ),
          );
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                AppLocalizations.of(context).translate('signInGoogleText'),
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        signUp(emailTextFieldController.text, passwordTextFieldController.text)
            .whenComplete(() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return MyHomePage();
              },
            ),
          );
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Image(image: AssetImage("assets/register_ffd.png"), height: 35.0),
            Icon(
              Icons.add_box,
              size: 35,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                AppLocalizations.of(context).translate('registerUser'),
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        signIn(emailTextFieldController.text, passwordTextFieldController.text)
            .whenComplete(() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return MyHomePage();
              },
            ),
          );
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Image(image: AssetImage("assets/register_ffd.png"), height: 35.0),
            Icon(
              Icons.input,
              size: 35,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                AppLocalizations.of(context).translate('loginUser'),
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

validateToken(token) async {
  print("Validating $token");

  String uri =
      'http://192.168.0.21:5000/api/ffd/validateDummyToken/?token=$token';

  print(uri);

  var amounts = await http.read(uri);

  print("Response: $amounts");
  return true;
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue[100], Colors.blue[400]],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(
                  imageUrl,
                ),
                radius: 60,
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: 40),
              Text(
                'NAME',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              Text(
                name,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'EMAIL',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              Text(
                email,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'TOKEN',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              Text(
                token != null
                    ? token.substring(0, 20) +
                        " - " +
                        token.substring(token.length - 20, token.length)
                    : "initializing",
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              RaisedButton(
                onPressed: () {
                  validateToken(token);
                },
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Validate',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
              RaisedButton(
                onPressed: () {
                  signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }), ModalRoute.withName('/'));
                },
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
