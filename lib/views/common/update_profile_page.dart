import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/models/user.dart' as AppUser;

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  String? _username;
  String? _phoneNumber;
  File? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      var userData = await DatabaseService().fetchUserById(user!.uid);
      if (userData != null) {
        setState(() {
          _username = userData.username;
          _phoneNumber = userData.phoneNumber;
          _profileImageUrl = userData.profilePictureUrl;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage != null) {
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_pics/${user!.uid}');
      await storageRef.putFile(_profileImage!);
      _profileImageUrl = await storageRef.getDownloadURL();
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _uploadImage();

      // Fetch the current user data
      var currentUserData = await DatabaseService().fetchUserById(user!.uid);

      // Create an updated user object with only the fields that need to be updated
      final updatedUser = AppUser.User(
        userId: currentUserData!.userId,
        username: _username ?? currentUserData.username,
        email: currentUserData.email,
        birthdate: currentUserData.birthdate,
        phoneNumber: _phoneNumber ?? currentUserData.phoneNumber,
        registerDate: currentUserData.registerDate,
        role: currentUserData.role,
        createdProjects: currentUserData.createdProjects,
        backedProjects: currentUserData.backedProjects,
        profilePictureUrl:
            _profileImageUrl ?? currentUserData.profilePictureUrl,
      );

      await DatabaseService().updateUser(user!.uid, updatedUser);

      // Pass true to indicate the profile was updated
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : NetworkImage(_profileImageUrl ??
                          'https://via.placeholder.com/150') as ImageProvider,
                ),
              ),
              TextFormField(
                initialValue: _username,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value;
                },
              ),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
