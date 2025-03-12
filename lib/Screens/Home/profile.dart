import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sdaemployee/Models/User.dart';
import 'package:sdaemployee/Screens/Address/view_address.dart';
import 'package:sdaemployee/Screens/Setup/login.dart';
import 'package:sdaemployee/Services/Routing/router.dart';
import 'package:sdaemployee/Widgets/Buttons.dart';
import 'package:sdaemployee/Widgets/Section.dart';
import '../../Services/Storage/share_prefs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
  bool isLoaded = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  void getUser() async {
    user = await SharePrefs().getUser();
    setState(() {
      isLoaded = true;
    });
  }

    Future<void> _loadProfileImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final File imageFile = File('${directory.path}/profile_image.jpg');

    if (imageFile.existsSync()) {
      setState(() {
        _profileImage = imageFile;
      });
    }
  }

  Future<void> _saveImageToLocalDirectory(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final File newImage = File('${directory.path}/profile_image.jpg');

    await image.copy(newImage.path);

    setState(() {
      _profileImage = newImage;
    });
  }

   Future<void> _showImageSourceDialog() async {
    final File? image = await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Image Source",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt,
                      size: 28, color: Colors.blueAccent),
                  title: const Text("Camera", style: TextStyle(fontSize: 16)),
                  onTap: () async {
                    final image = await _pickImage(ImageSource.camera);
                    Navigator.pop(context, image);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo,
                      size: 28, color: Colors.orangeAccent),
                  title: const Text("Gallery", style: TextStyle(fontSize: 16)),
                  onTap: () async {
                    final image = await _pickImage(ImageSource.gallery);
                    Navigator.pop(context, image);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (image != null) {
      await _saveImageToLocalDirectory(image);
    }
  }

  Future<File?> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
    return null;
  }

  @override
  void initState() {
    getUser();
    _loadProfileImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoaded
          ? SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Edit Button at the top right
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              // Add functionality for the edit button
                            },
                            child: Icon(
                              Icons.edit,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Profile Image Section
                        Center(
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : (user.profile != null
                                      ? NetworkImage(user.profile!)
                                      : null) as ImageProvider?,
                              child:
                                  _profileImage == null && user.profile == null
                                      ? const Icon(Icons.camera_alt,
                                          size: 40, color: Colors.white)
                                      : null,
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // User Name Section
                        Center(
                          child: Text(
                            user.first_name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Personal Details Section
                  Section().buildSectionTitle("Personal Details"),
                  Section().builButtonCard(
                    [
                      Section().buildDetailRow(
                        "Name",
                        "${user.first_name} ${user.last_name}",
                        Icons.person,
                        Colors.orangeAccent,
                      ),
                      Section().buildDetailRow(
                          "Middle Name",
                          user.middle_name ?? "-",
                          Icons.person,
                          Colors.blueAccent),
                      Section().buildDetailRow(
                        "Mobile",
                        user.mobile,
                        Icons.phone,
                        Colors.orangeAccent,
                      ),
                      Section().buildDetailRow(
                          "Email", user.email, Icons.email, Colors.blueAccent),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Section().buildSectionTitle("Account Details"),

                  Section().builButtonCard(
                    [
                      Buttons().buildListTile(
                        icon: Icons.location_on,
                        title: "Address",
                        subtitle: "Personal Address",
                        color: Colors.blueAccent,
                        onTap: () {
                          ScreenRouter.addScreen(context, ViewAddress(user_id: user.user_id.toString(),));
                        },
                      ),
                      // Buttons().buildListTile(
                      //   icon: Icons.account_balance,
                      //   title: "KYC",
                      //   subtitle: "Bank Information",
                      //   color: Colors.orangeAccent,
                      //   onTap: () {
                      //     ScreenRouter.addScreen(context, ViewKyc());
                      //   },
                      // ),
                    ],
                  ),

                  // Account Details Section

                  const SizedBox(height: 20),

                  // General Section
                  Section().buildSectionTitle("Log IN"),
                  Section().builButtonCard(
                    [
                      Buttons().buildListTile(
                        icon: Icons.logout,
                        title: "Logout",
                        subtitle: "Logout from account",
                        color: Colors.blueAccent,
                        onTap: () async {
                          bool log = await SharePrefs().logout();
                          if (log) {
                            ScreenRouter.replaceScreen(
                                context, const LoginScreen());
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
