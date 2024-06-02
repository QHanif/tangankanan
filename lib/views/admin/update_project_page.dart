import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/services/database_service.dart';
import 'package:tangankanan/views/style.dart';

class UpdateProjectPage extends StatefulWidget {
  final Project project;

  const UpdateProjectPage({Key? key, required this.project}) : super(key: key);

  @override
  _UpdateProjectPageState createState() => _UpdateProjectPageState();
}

class _UpdateProjectPageState extends State<UpdateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _projectPicUrl;
  late double _fundGoal;
  late DateTime _startDate;
  late DateTime _endDate;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _title = widget.project.title;
    _description = widget.project.description;
    _projectPicUrl = widget.project.projectPicUrl;
    _fundGoal = widget.project.fundGoal;
    _startDate = widget.project.startDate;
    _endDate = widget.project.endDate;
  }

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
            : ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  _projectPicUrl,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
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
    required DateTime selectedDate,
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
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      controller: TextEditingController(
        text: selectedDate.toLocal().toString().split(' ')[0],
      ),
      validator: (value) =>
          value == null || value.isEmpty ? '$labelText is required' : null,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Upload the image if one is selected
      if (_imageFile != null) {
        _projectPicUrl =
            await _uploadImage(_imageFile!, widget.project.projectId) ??
                _projectPicUrl;
      }

      // Create an updated project object using copyWith
      final updatedProject = widget.project.copyWith(
        title: _title,
        description: _description,
        projectPicUrl: _projectPicUrl,
        fundGoal: _fundGoal,
        startDate: _startDate,
        endDate: _endDate,
      );

      // Update the project in Firestore
      await DatabaseService()
          .updateProject(widget.project.projectId, updatedProject);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Update Project'),
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
                _buildTextFormField(
                  labelText: 'Project Title',
                  initialValue: _title,
                  onSaved: (value) => _title = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  labelText: 'Project description',
                  initialValue: _description,
                  onSaved: (value) => _description = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Description is required' : null,
                  maxLines: 4,
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  labelText: 'Funding Goal (MYR)',
                  initialValue: _fundGoal.toString(),
                  onSaved: (value) => _fundGoal = double.tryParse(value!)!,
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
                            setState(() => _startDate = date!),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePicker(
                        labelText: 'End date',
                        selectedDate: _endDate,
                        onDateSelected: (date) =>
                            setState(() => _endDate = date!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: AppStyles.primaryButtonStyle,
                  onPressed: _submitForm,
                  child: Text(
                    'Save Changes',
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
