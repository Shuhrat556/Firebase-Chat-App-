// // screens/profile_screen.dart
// import 'dart:io';

// import 'package:chat/models/user_profile.dart';
// import 'package:chat/service/auth/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class ProfileScreen extends StatefulWidget {
//   final String userId;
//   final bool isCurrentUser;

//   const ProfileScreen({
//     super.key,
//     required this.userId,
//     this.isCurrentUser = false,
//   });

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   late Future<UserProfile> _profileFuture;
//   final AuthService _authService = AuthService();
//   File? _imageFile;

//   @override
//   void initState() {
//     super.initState();
//     _profileFuture = _authService.getProfile(widget.userId);
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _saveProfile(UserProfile profile) async {
//     String? photoUrl = profile.photoUrl;

//     if (_imageFile != null) {
//       photoUrl = await _authService.uploadProfileImage(_imageFile!);
//     }

//     UserProfile updatedProfile = profile.copyWith(
//       photoUrl: photoUrl ?? profile.photoUrl,
//     );

//     await _authService.updateProfile(updatedProfile);
//     setState(() {
//       _profileFuture = _authService.getProfile(widget.userId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         actions: [
//           if (widget.isCurrentUser)
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () => _showEditDialog(context),
//             ),
//         ],
//       ),
//       body: FutureBuilder<UserProfile>(
//         future: _profileFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError || !snapshot.hasData) {
//             return const Center(child: Text('Error loading profile'));
//           }

//           final profile = snapshot.data!;

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Center(
//                   child: Stack(
//                     children: [
//                       CircleAvatar(
//                         radius: 60,
//                         backgroundImage:
//                             profile.photoUrl != null
//                                 ? NetworkImage(profile.photoUrl!)
//                                 : const AssetImage('assets/default_avatar.png')
//                                     as ImageProvider,
//                         child:
//                             _imageFile != null
//                                 ? ClipOval(
//                                   child: Image.file(
//                                     _imageFile!,
//                                     width: 120,
//                                     height: 120,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                                 : null,
//                       ),
//                       if (widget.isCurrentUser)
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: IconButton(
//                             icon: Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.camera_alt,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                             onPressed: _pickImage,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   profile.name,
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   profile.email,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//                 const SizedBox(height: 20),
//                 if (profile.bio != null && profile.bio!.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Text(
//                       profile.bio!,
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                   ),
//                 const SizedBox(height: 20),
//                 Chip(
//                   label: Text(profile.status),
//                   backgroundColor:
//                       profile.status == 'Online'
//                           ? Colors.green[100]
//                           : Colors.grey[300],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showEditDialog(BuildContext context) {
//     TextEditingController nameController = TextEditingController();
//     TextEditingController bioController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return FutureBuilder<UserProfile>(
//           future: _profileFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             final profile = snapshot.data!;
//             nameController.text = profile.name;
//             bioController.text = profile.bio ?? '';

//             return AlertDialog(
//               title: const Text('Edit Profile'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: nameController,
//                     decoration: const InputDecoration(labelText: 'Name'),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: bioController,
//                     decoration: const InputDecoration(labelText: 'Bio'),
//                     maxLines: 3,
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     UserProfile updatedProfile = profile.copyWith(
//                       name: nameController.text,
//                       bio: bioController.text,
//                     );
//                     await _saveProfile(updatedProfile);
//                     // ignore: use_build_context_synchronously
//                     Navigator.pop( context);
//                   },
//                   child: const Text('Save'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
