import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:stamped/features/workspace/workspace_provider.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/core/theme/app_colors.dart';
import 'package:stamped/core/services/cloudinary_service.dart';
import 'package:stamped/features/workspace/team_selection_screen.dart';
import 'package:stamped/features/workspace/widgets/project_selection_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stamped/features/camera/camera_provider.dart';
import 'package:stamped/core/models/photo_model.dart';
import 'package:stamped/core/models/project_model.dart';
import 'package:stamped/features/workspace/member_profile_screen.dart';
import 'package:stamped/features/workspace/project_details_screen.dart';
import 'package:stamped/features/workspace/network_photo_viewer_screen.dart';

class WorkspaceDashboardScreen extends StatefulWidget {
  const WorkspaceDashboardScreen({super.key});

  @override
  State<WorkspaceDashboardScreen> createState() => _WorkspaceDashboardScreenState();
}

class _WorkspaceDashboardScreenState extends State<WorkspaceDashboardScreen> {
  int _bottomNavIndex = 0;
  // Removed manual _uploadImage function

  void _showInviteCodeDialog(String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Members'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this code with team members to let them join your workspace:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade100,
              child: Text(code, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildLibraryTab(BuildContext context, WorkspaceProvider wp) {
    final currentWorkspace = wp.currentWorkspace;
    
    if (currentWorkspace == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No workspace selected"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamSelectionScreen())),
              child: const Text('Select or Create Team'),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Top
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamSelectionScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Text(
                    currentWorkspace.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.chevronDown),
                  const Spacer(),
                  const Icon(LucideIcons.monitor),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.x),
                  ),
                ],
              ),
            ),
          ),
          
          // Auto Save toggle (Visuals only for now)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.camera, color: AppColors.textBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Auto save to ${currentWorkspace.name}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const Text("On", style: TextStyle(color: Colors.grey)),
                const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Members Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${currentWorkspace.memberIds.length} Members', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(LucideIcons.userPlus),
                  onPressed: () {
                    if (currentWorkspace.joinCode != null) {
                      _showInviteCodeDialog(currentWorkspace.joinCode!);
                    }
                  },
                ),
              ],
            ),
          ),
          
          SizedBox(
            height: 120, // Slightly taller to fit names/emails
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: currentWorkspace.memberIds.length,
              itemBuilder: (context, index) {
                final memberId = currentWorkspace.memberIds[index];
                final isOwner = currentWorkspace.ownerId == memberId;
                
                return FutureBuilder<Map<String, dynamic>?>(
                  future: wp.workspaceService.getUserProfile(memberId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    
                    final profile = snapshot.data;
                    final displayName = profile?['displayName'] ?? 'Unknown';
                    final photoUrl = profile?['photoUrl'] as String?;
                    
                    return GestureDetector(
                      onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemberProfileScreen(memberId: memberId),
                            ),
                          );
                      },
                      child: Container(
                        width: 100, // wider for text
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty 
                                      ? NetworkImage(photoUrl) 
                                      : null,
                                    child: photoUrl == null || photoUrl.isEmpty ? Text(displayName.substring(0, 1).toUpperCase()) : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Text(
                                      displayName, 
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), 
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (profile?['email'] != null)
                                    Padding( // Optional subtext, though small space
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Text(
                                        profile!['email'], 
                                        style: const TextStyle(fontSize: 9, color: Colors.grey), 
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isOwner)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Owner', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Projects Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(LucideIcons.plus),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const ProjectSelectionSheet(),
                    );
                  },
                ),
              ],
            ),
          ),
          
          StreamBuilder<List<ProjectModel>>(
            stream: wp.workspaceService.getWorkspaceProjects(currentWorkspace.id),
            builder: (context, projectSnapshot) {
              if (projectSnapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()));
              }
              final projects = projectSnapshot.data ?? [];
              
              if (projects.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("No projects yet.", style: TextStyle(color: Colors.grey)),
                );
              }

              return SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailsScreen(project: project),
                          ),
                        );
                      },
                      onLongPress: () {
                        // Delete project logic
                        if (currentWorkspace.ownerId == Provider.of<AuthProvider>(context, listen: false).user?.uid) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Project'),
                              content: Text('Are you sure you want to delete "${project.name}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance.collection('projects').doc(project.id).delete();
                                    Navigator.pop(ctx);
                                  }, 
                                  child: const Text('Delete', style: TextStyle(color: Colors.red))
                                ),
                              ],
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only the workspace owner can delete projects.')));
                        }
                      },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.folder, color: Colors.blueAccent),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Text(
                                  project.name, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                  .collection('photos')
                                  .where('workspaceId', isEqualTo: currentWorkspace.id)
                                  .where('projectId', isEqualTo: project.id)
                                  .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final count = snapshot.data!.docs.length;
                                    return Text(
                                      '$count image${count == 1 ? '' : 's'}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    );
                                  }
                                  return const Text(
                                    'Loading...',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                    );
                  },
                ),
              );
            }
          ),
          
          const SizedBox(height: 24),
          
          // Photos Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('All Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
          StreamBuilder<List<PhotoModel>>(
            stream: wp.workspaceService.getWorkspacePhotos(currentWorkspace.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final photos = snapshot.data ?? [];
              
              if (photos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No photos uploaded yet."),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NetworkPhotoViewerScreen(photo: photo),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        photo.cloudinaryUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 100), // Padding for fab and trial banner
        ],
      ),
    );
  }

  Widget _buildCurrentTab(BuildContext context, WorkspaceProvider wp) {
    switch (_bottomNavIndex) {
      case 0:
        return _buildLibraryTab(context, wp);
      case 1:
        return _buildToolsTab();
      case 2:
        return _buildSearchTab();
      case 3:
        return _buildSettingsTab(wp);
      default:
        return _buildLibraryTab(context, wp);
    }
  }

  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Tools', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _toolCard(LucideIcons.fileSpreadsheet, 'Excel Report', 'Export workspace data to Excel'),
        _toolCard(LucideIcons.fileText, 'PDF Report', 'Generate a PDF summary'),
        _toolCard(LucideIcons.history, 'File Version Report', 'View document iterations'),
      ],
    );
  }

  Widget _toolCard(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(LucideIcons.chevronRight, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('\$title export coming soon!')));
        },
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Search', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search images, persons, projects...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Recent Searches', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          // Placeholder for recent searches
          const ListTile(
            leading: Icon(LucideIcons.history, size: 18),
            title: Text('Site Survey 12', style: TextStyle(fontSize: 14)),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsTab(WorkspaceProvider wp) {
    final currentWorkspace = wp.currentWorkspace;
    if (currentWorkspace == null) {
      return const Center(child: Text("No Workspace Selected"));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        
        const Text('Workspace Details', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Workspace Name'),
          subtitle: Text(currentWorkspace.name),
          trailing: const Icon(LucideIcons.edit2, size: 16),
          onTap: () {
            // Edit name logic
          },
        ),
        ListTile(
          title: const Text('Workspace Owner ID'),
          subtitle: Text(currentWorkspace.ownerId),
        ),
        
        const SizedBox(height: 24),
        const Text('Access & Members', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Total Members'),
          subtitle: Text('${currentWorkspace.memberIds.length} members'),
        ),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(LucideIcons.logOut, color: Colors.red),
          title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      authProvider.signOut();
                      Navigator.pop(ctx); // close dialog
                      // Pop back to camera screen (or auth screen)
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }, 
                    child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WorkspaceProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildCurrentTab(context, wp),
            ),
            
            // Removed FAB because uploading is now automatic on capture
            // Trial Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("14 days left on trial", style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      Text("Upgrade", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                      Icon(LucideIcons.chevronRight, size: 16, color: Colors.blue.shade700),
                    ],
                  ),
                ],
              ),
            ),
            
            // Custom Bottom Nav
            Container(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(0, 'Library', LucideIcons.folderClosed),
                  _navItem(1, 'Tools', LucideIcons.layoutGrid),
                  _navItem(2, 'Search', LucideIcons.search),
                  _navItem(3, 'Settings', LucideIcons.settings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, String label, IconData icon) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              fontSize: 12, 
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
