import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tangankanan/models/project.dart';
import 'package:tangankanan/models/update.dart';
import 'package:tangankanan/views/style.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CommunityUpdatesPage extends StatefulWidget {
  final Project project;

  const CommunityUpdatesPage({Key? key, required this.project})
      : super(key: key);

  @override
  _CommunityUpdatesPageState createState() => _CommunityUpdatesPageState();
}

class _CommunityUpdatesPageState extends State<CommunityUpdatesPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _postUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and description cannot be empty')),
      );
      return;
    }

    final newUpdate = Update(
      updateId: FirebaseFirestore.instance.collection('updates').doc().id,
      projectId: widget.project.projectId,
      title: _titleController.text,
      description: _descriptionController.text,
      date: DateTime.now(),
    );

    if (_image != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('updates/${newUpdate.updateId}.jpg');
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();
      newUpdate.imageUrl = imageUrl;
    }

    await FirebaseFirestore.instance
        .collection('updates')
        .doc(newUpdate.updateId)
        .set(newUpdate.toJson());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update posted successfully')),
    );

    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Post Community Update'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _image == null
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          height: 200,
                          width: double.infinity,
                          child: Icon(Icons.add_a_photo,
                              size: 50, color: Colors.grey[700]),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                          height: 200,
                          width: double.infinity,
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 10),
              _buildTextFormField(
                labelText: 'Update Title',
                onSaved: (value) => _titleController.text = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              _buildTextFormField(
                labelText: 'Update Description',
                onSaved: (value) => _descriptionController.text = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description cannot be empty';
                  }
                  return null;
                },
                maxLines: 5,
              ),
              SizedBox(height: 20),
              Center(
                child: AppStyles.button('Post Update', _postUpdate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
