import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_time_translation_application/firebase/wrapper.dart';
import 'package:real_time_translation_application/screens/edit_profile_screen.dart';
import '../widgets/back_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  File? _image;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          userData = snapshot.get('user_details') as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Failed to fetch user data: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          const Expanded(child: Text('Uploading profile picture...')),
        ],
      ),
      duration: const Duration(days: 1),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user?.uid}.jpg');

      UploadTask uploadTask = ref.putFile(_image!);
      await uploadTask;

      String downloadURL = await ref.getDownloadURL();

      // Save the download URL to Firestore under 'user_details'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'user_details.profileImage': downloadURL,
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );

      setState(() {
        userData?['profileImage'] = downloadURL;
      });
    } catch (e) {
      print("Error during upload: $e");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BackAppBar(
        title: "My Profile",
        onMorePressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: userData!['profileImage'] != null
                      ? NetworkImage(userData!['profileImage'])
                      : const AssetImage('assets/icon.jpg') as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              userData!['username'] ?? 'N/A',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              userData!['phoneNumber'] ?? 'N/A',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildDetailRow("LOCATION :", userData!['location'] ?? 'N/A'),
            _buildDetailRow("EMAIL :", userData!['email'] ?? 'N/A'),
            _buildDetailRow("BIRTHDAY :", userData!['birthday'] ?? 'N/A'),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
  onPressed: () async {
    // Navigate to EditProfileScreen and wait for updated data
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    // Check if data is returned and update the state
    if (updatedData != null && mounted) {
      setState(() {
        userData?.addAll(updatedData as Map<String, dynamic>);
      });
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(191, 246, 21, 5),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    textStyle: const TextStyle(fontSize: 18),
  ),
  child: const Text("EDIT"),
),

                ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("LOGOUT"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.blue, fontSize: 16)),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Wrapper()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }
}