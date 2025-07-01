import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrismart/widgets/random_scaffold.dart'; // Assuming this is your custom scaffold
import 'package:agrismart/theme/theme.dart'; // Assuming this is your theme file

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _imageFile;
  String? _avatarUrl;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    final userEmail = user.email; // Get the current user's email
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email not available!')),
      );
      return;
    }


    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch profile using the user's email
      final response = await Supabase.instance.client
          .from('profile') // Your profiles table
          .select('image_path') // Column storing the path in the 'prof' bucket
          .eq('email', userEmail) // Query by user's email
          .single();

      if (response != null && response['image_path'] != null) {
        final String avatarPath = response['image_path'] as String;
        // Get the public URL from the 'prof' storage bucket
        final String publicUrl = Supabase.instance.client.storage
            .from('prof') // Your storage bucket name
            .getPublicUrl(avatarPath);

        setState(() {
          _avatarUrl = publicUrl;
        });
      }
    } catch (e) {
      // Handle case where profile doesn't exist or other errors
      print('Error loading profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile picture: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _avatarUrl = null; // Clear existing avatar URL when a new image is picked
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    final userEmail = user.email; // Get the current user's email
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email not available!')),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image to upload.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Define the path for the image in the 'prof' storage bucket
      final String imagePath = 'profile_pictures/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload the image file to the 'prof' bucket
      final fileBytes = await _imageFile!.readAsBytes();
      final uploadResult = await Supabase.instance.client.storage
          .from('prof')
          .uploadBinary(imagePath, fileBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

      // THIS IS WHERE YOUR SNIPPET IS ALREADY LOCATED:
      await Supabase.instance.client
          .from('profile')
          .upsert({
        'email': userEmail, // Link to the user via email
        'image_path': imagePath, // Store the storage path
      }, onConflict: 'email');


      // Get the public URL to display the newly uploaded image
      final String publicUrl = Supabase.instance.client.storage
          .from('prof')
          .getPublicUrl(imagePath);

      setState(() {
        _avatarUrl = publicUrl;
        _imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error uploading profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile picture: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return RandomScaffold(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            flex: 70,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: lightColorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider
                            : (_avatarUrl != null
                            ? NetworkImage(_avatarUrl!) as ImageProvider
                            : null),
                        child: _imageFile == null && _avatarUrl == null
                            ? Icon(Icons.camera_alt, size: 50, color: Colors.grey[600])
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Profile Picture'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _uploadProfilePicture,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Upload Profile Picture'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
