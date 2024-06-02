import 'package:flutter/material.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/services/auth_service.dart';
import 'package:tangankanan/models/user.dart';
import 'package:tangankanan/views/style.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({Key? key}) : super(key: key);

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = DatabaseService().fetchUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = DatabaseService().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Users'),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found'));
          } else {
            // Filter out users with the role 'admin'
            final users =
                snapshot.data!.where((user) => user.role != 'admin').toList();
            if (users.isEmpty) {
              return Center(child: Text('No users found'));
            }
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: user.role == 'backer'
                          ? LinearGradient(
                              colors: [Colors.white, Colors.lightBlue.shade100],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : user.role == 'creator'
                              ? LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.lightGreen.shade100
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                      color: user.role != 'backer' && user.role != 'creator'
                          ? Colors.white
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(user.profilePictureUrl),
                                radius: 30,
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(user.email),
                                  Text(
                                    user.role.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: user.role == 'backer'
                                          ? Colors.blue.shade800
                                          : user.role == 'creator'
                                              ? Colors.green.shade800
                                              : Colors
                                                  .black, // Default color for other roles
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle user deletion
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Delete User'),
                                        content: Text(
                                            'Are you sure you want to delete this user?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Dismiss alert dialog
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              try {
                                                if (user.userId.isNotEmpty) {
                                                  await Auth()
                                                      .deleteUser(user.userId);
                                                  await DatabaseService()
                                                      .deleteUser(user.userId);
                                                  await DatabaseService()
                                                      .deleteUserProfileImage(
                                                          user.userId);
                                                  print(
                                                      'User and profile picture deleted successfully');
                                                  await _refreshUsers(); // Refresh the user list
                                                } else {
                                                  print('User ID is empty');
                                                }
                                              } catch (e) {
                                                print(
                                                    'Error deleting user or profile picture: $e');
                                              }
                                              Navigator.of(context)
                                                  .pop(); // Dismiss alert dialog
                                            },
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text('Delete User',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
