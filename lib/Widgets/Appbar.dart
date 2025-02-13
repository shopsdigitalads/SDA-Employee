import 'package:flutter/material.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Services/Storage/share_prefs.dart';

class AppbarClass {
  Future<User> getUser() async {
    User user = await SharePrefs().getUser();
    return user;
  }

  AppBar buildHomeAppBar() {
    return AppBar(
      toolbarHeight: 70,
      elevation: 4,
      backgroundColor: Colors.white70,
      centerTitle: false,
       flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white], // Add gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: FutureBuilder<User>(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              children: [
                SizedBox(width: 5),
                Image.asset(
                  'assets/logo1.png',
                  height: 50,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "Loading...", // Placeholder while waiting
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Row(
              children: [
                SizedBox(width: 5),
                Image.asset(
                  'assets/logo1.png',
                  height: 50,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "Error!", // Display error message
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            User user = snapshot.data!;
            return Row(
              children: [
                SizedBox(width: 5),
                Image.asset(
                  'assets/logo1.png',
                  height: 50,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      user.first_name, // Display the user's name
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
      actions: [
        IconButton(
          iconSize: 25,
          onPressed: () {},
          icon: Icon(Icons.notifications, color: Colors.black87),
        ),
        PopupMenuButton(
          iconSize: 25,
          icon: Icon(Icons.more_vert, color: Colors.black87),
          onSelected: (value) {
            // Handle menu selection
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'Option 1',
              child: Text('Option 1'),
            ),
            PopupMenuItem(
              value: 'Option 2',
              child: Text('Option 2'),
            ),
          ],
        ),
      ],
    );
  }

  /// AppBar for sub-screens
  AppBar buildSubScreenAppBar(BuildContext context, String screenName) {
    return AppBar(
      elevation: 4,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: Text(
        screenName, // Display the screen name
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Image.asset(
            'assets/logo1.png', // Replace with your logo asset
            height: 50,
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16), // Add rounded corners at the bottom
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white], // Add gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
