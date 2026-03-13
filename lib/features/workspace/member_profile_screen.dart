import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/core/models/photo_model.dart';
import 'package:stamped/features/workspace/network_photo_viewer_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MemberProfileScreen extends StatelessWidget {
  final String memberId;

  const MemberProfileScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WorkspaceProvider>(context);
    final currentWorkspace = wp.currentWorkspace;

    if (currentWorkspace == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Member Profile')),
        body: const Center(child: Text('No workspace selected')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>?>(
          future: wp.workspaceService.getUserProfile(memberId),
          builder: (context, snapshot) {
            final name = snapshot.data?['displayName'] ?? 'Member';
            return Text(name, style: const TextStyle(color: Colors.black));
          }
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<PhotoModel>>(
        stream: wp.workspaceService.getWorkspacePhotos(currentWorkspace.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final allPhotos = snapshot.data ?? [];
          final memberPhotos = allPhotos.where((p) => p.uploaderId == memberId).toList();
          
          // Group photos by date string
          final Map<String, List<PhotoModel>> groupedPhotos = {};
          final DateFormat dateFormatter = DateFormat('MMM d, yyyy');
          
          for (var photo in memberPhotos) {
            final dateStr = dateFormatter.format(photo.timestamp);
            if (!groupedPhotos.containsKey(dateStr)) {
              groupedPhotos[dateStr] = [];
            }
            groupedPhotos[dateStr]!.add(photo);
          }
          
          final sortedDateKeys = groupedPhotos.keys.toList(); // Already mostly sorted because stream is desc

          return Column(
            children: [
              // Header section with user details
              FutureBuilder<Map<String, dynamic>?>(
                future: wp.workspaceService.getUserProfile(memberId),
                builder: (context, profileSnapshot) {
                  if (profileSnapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  final profile = profileSnapshot.data;
                  final displayName = profile?['displayName'] ?? 'Unknown Member';
                  final email = profile?['email'] ?? 'No email available';
                  final photoUrl = profile?['photoUrl'] as String?;
                  String lastLoginStr = 'Unknown';
                  
                  if (profile?['lastLogin'] != null) {
                    final timestamp = profile!['lastLogin'] as Timestamp;
                    lastLoginStr = DateFormat('MMM d, yyyy  h:mm a').format(timestamp.toDate());
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: photoUrl != null && photoUrl.isNotEmpty 
                            ? NetworkImage(photoUrl) 
                            : null,
                          child: (photoUrl == null || photoUrl.isEmpty) 
                            ? Text(displayName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 32)) 
                            : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Last seen: $lastLoginStr',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text('${memberPhotos.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const Text('Photos', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              ),
              const Divider(height: 1),
              
              if (memberPhotos.isEmpty)
                const Expanded(
                  child: Center(child: Text("No photos uploaded yet.", style: TextStyle(color: Colors.grey))),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedDateKeys.length,
                    itemBuilder: (context, index) {
                      final dateStr = sortedDateKeys[index];
                      final photosForDate = groupedPhotos[dateStr]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              dateStr,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                            ),
                            itemCount: photosForDate.length,
                            itemBuilder: (context, photoIndex) {
                              final photo = photosForDate[photoIndex];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NetworkPhotoViewerScreen(photo: photo),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  photo.cloudinaryUrl,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
