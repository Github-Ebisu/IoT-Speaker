import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../cloud_functions/auth_service.dart';
import '../../models/user.dart';

import 'account/account.dart';
import 'music/music.dart';

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _currentPage = 0;

  final List<Widget> _page = [
    const MusicPage(title: "Music"),
    const AccountPage(),
    // const TimeNavigator(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModels?>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/avatar.jpeg"),
              ),
              SizedBox(width: 10.0),
              Text(
                "Welcome !",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white,
        currentIndex: _currentPage,
        onTap: (int index) {
          setState(() {
            _currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(
              Icons.home,
            ),
          ),
          BottomNavigationBarItem(
            label: "Account",
            icon: Icon(
              Icons.person,
            ),
          ),
        ],
      ),
      body: _page[_currentPage],
    );
  }
}
