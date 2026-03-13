import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/core/models/photo_model.dart';

class FullScreenImageViewer extends StatelessWidget {
  final PhotoModel photo;

  const FullScreenImageViewer({super.key, required this.photo});

  void _deletePhoto(BuildContext context, WorkspaceProvider wp) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await wp.workspaceService.deletePhoto(photo.id);
      if (context.mounted) {
        Navigator.pop(context); // Close viewer after delete
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo deleted')));
      }
    }
  }

  void _movePhoto(BuildContext context, WorkspaceProvider wp) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StreamBuilder(
          stream: wp.workspaceService.getWorkspaceProjects(photo.workspaceId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final projects = snapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(title: const Text('Move to Project'), automaticallyImplyLeading: false),
              body: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ListTile(
                    title: Text(project.name),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await wp.workspaceService.movePhoto(photo.id, project.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moved to ${project.name}')));
                      }
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _downloadPhoto(BuildContext context) {
    // Scaffold UI logic for downloading - In real app, you would use dio/http to save to gallery
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading image...')));
  }

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WorkspaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    
    final isOwner = wp.currentWorkspace?.ownerId == auth.user?.uid;
    final isUploader = photo.uploaderId == auth.user?.uid;
    final canManage = isOwner || isUploader;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () => _downloadPhoto(context),
          ),
          if (canManage) ...[
            IconButton(
              icon: const Icon(LucideIcons.folderInput),
              onPressed: () => _movePhoto(context, wp),
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.red),
              onPressed: () => _deletePhoto(context, wp),
            ),
          ],
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            photo.cloudinaryUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
