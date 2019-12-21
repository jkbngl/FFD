import 'package:flutter/material.dart';

class NavToNewPageBottomNav extends StatefulWidget {
  @override
  NavToNewPageBottomNavState createState() {
    return new NavToNewPageBottomNavState();
  }
}

class NavToNewPageBottomNavState extends State<NavToNewPageBottomNav> {
  String text = 'Home';

  _onTap(int index) {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
      return new NewPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Navigate to new Page from Bottom Nav Bar Example"),
      ),
      body: Center(
        child: Text(text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Goto Page"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text("New Page"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text("Settings"),
          ),
        ],
        onTap: _onTap,
      ),
    );
  }
}

class NewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Page")),
      body: Center(
          child: Text("New Page",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold))),
    );
  }
}
