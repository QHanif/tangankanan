import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/services/auth_service.dart'; // Import your AuthService to get the current user ID
import 'package:tangankanan/views/style.dart'; // Import the style file

class AdminCreateProjectPage extends StatefulWidget {
  @override
  _AdminCreateProjectPageState createState() => _AdminCreateProjectPageState();
}

class _AdminCreateProjectPageState extends State<AdminCreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  String? _projectPicUrl;
  double? _fundGoal;
  DateTime? _startDate;
  DateTime? _endDate;
  XFile? _imageFile;
  String? _creatorName;
  bool _isCreatorValid = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<String?> _uploadImage(XFile imageFile, String projectId) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('project_images/$projectId');
      final uploadTask = storageRef.putFile(File(imageFile.path));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(_imageFile!.path),
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                  Text('Upload a picture'),
                ],
              ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        labelStyle: TextStyle(color: Colors.black54),
        labelText: labelText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: AppColors.textFieldBorder),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildDatePicker({
    required String labelText,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        labelStyle: TextStyle(color: Colors.black54),
        labelText: labelText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: AppColors.textFieldBorder),
        ),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(), // Prevent picking past dates
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      controller: TextEditingController(
        text: selectedDate != null
            ? selectedDate.toLocal().toString().split(' ')[0]
            : '',
      ),
      validator: (value) =>
          selectedDate == null ? '$labelText is required' : null,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Get the current user ID
      final userId = Auth().currentUser?.uid;
      if (userId == null) {
        // Handle the case where the user is not logged in
        return;
      }

      // Fetch the creator's user ID based on the creator name
      final creatorQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: _creatorName)
          .where('role', isEqualTo: 'creator')
          .get();

      if (creatorQuery.docs.isEmpty) {
        // Handle the case where the creator is not found
        setState(() {
          _isCreatorValid = false;
        });
        return;
      }

      final creatorId = creatorQuery.docs.first.id;
      setState(() {
        _isCreatorValid = true;
      });

      // Generate a new document reference to get the document ID
      final docRef = FirebaseFirestore.instance.collection('projects').doc();

      // Create a new project object with the generated document ID
      final newProject = Project(
        projectId: docRef.id, // Use the generated document ID
        creatorId: creatorId, // Use the creator's user ID
        title: _title!,
        description: _description!,
        projectPicUrl:
            '', // Temporary empty URL, will be updated after image upload
        fundGoal: _fundGoal!,
        currentFund: 0.0,
        startDate: _startDate ?? DateTime.now(),
        endDate: _endDate ?? DateTime.now().add(Duration(days: 30)),
        verificationStatus: 'verified',
        backers: [],
        updates: [],
        projectStatus: 'ongoing', // Set the default project status to 'ongoing'
      );

      // Save the project to Firestore to get the document ID
      await docRef.set(newProject.toJson());

      // Upload the image if one is selected
      if (_imageFile != null) {
        _projectPicUrl = await _uploadImage(_imageFile!, docRef.id);
        // Update the project with the image URL
        await docRef.update({'projectPicUrl': _projectPicUrl});
      }

      // Add the project ID to the creator's createdProjects array
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(creatorId);
      await userDocRef.update({
        'createdProjects': FieldValue.arrayUnion([docRef.id])
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create new project'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePicker(),
                SizedBox(height: 16),
                if (!_isCreatorValid && _creatorName != null)
                  Text(
                    'Creator not found',
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 16),
                _buildTextFormField(
                  labelText: 'Creator Name',
                  onSaved: (value) => _creatorName = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Creator Name is required' : null,
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  labelText: 'Project Title',
                  onSaved: (value) => _title = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  labelText: 'Project description',
                  onSaved: (value) => _description = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Description is required' : null,
                  maxLines: 4,
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  labelText: 'Funding Goal (MYR)',
                  onSaved: (value) => _fundGoal = double.tryParse(value!),
                  validator: (value) =>
                      value!.isEmpty ? 'Fund Goal is required' : null,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        labelText: 'Start date',
                        selectedDate: _startDate,
                        onDateSelected: (date) =>
                            setState(() => _startDate = date),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePicker(
                        labelText: 'End date',
                        selectedDate: _endDate,
                        onDateSelected: (date) =>
                            setState(() => _endDate = date),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: AppStyles.primaryButtonStyle,
                  onPressed: _submitForm,
                  child: Text(
                    'Create Project',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
