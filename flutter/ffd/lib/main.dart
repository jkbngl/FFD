import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class AppFooter extends StatefulWidget {
  @override
  _AppFooterState createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  int _currentIndex = 0;

  List<Widget> _pages = [
    Text("page1"),
    Text("page2"),
    Text("page3"),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          new BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: _currentIndex == 0
                  ? new Image.asset('assets/images/dashboard_active.png')
                  : new Image.asset('assets/images/dashboard_inactive.png'),
              title:
              new Text('Dashboard', style: new TextStyle(fontSize: 12.0))),
          new BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: _currentIndex == 1
                  ? new Image.asset('assets/images/medical_sevice_active.png')
                  : new Image.asset(
                  'assets/images/medical_sevice_inactive.png'),
              title: new Text('Health Services',
                  style: new TextStyle(fontSize: 12.0))),
          new BottomNavigationBarItem(
              icon: InkWell(
                child: Icon(
                  Icons.format_align_left,
                  // color: green,
                  size: 20.0,
                ),
              ),
              title: new Text('History', style: new TextStyle(fontSize: 12.0))),
        ],
      ),
    );
  }
}