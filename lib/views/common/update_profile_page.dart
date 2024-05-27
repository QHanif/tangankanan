import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/models/user.dart' as AppUser;
import 'package:tangankanan/views/style.dart';

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
  late Future<void> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUserData();
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

  Widget _buildTextField(
      String labelText, String? initialValue, FormFieldSetter<String> onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue, // This sets the initial value
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: FutureBuilder(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _profileImageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      _profileImageUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt,
                                          size: 40, color: Colors.grey),
                                      Text('Upload a profile picture',
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                        'Username', _username, (value) => _username = value),
                    _buildTextField('Phone Number', _phoneNumber,
                        (value) => _phoneNumber = value),
                    SizedBox(height: 20),
                    AppStyles.button('Save Changes', _updateProfile),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
