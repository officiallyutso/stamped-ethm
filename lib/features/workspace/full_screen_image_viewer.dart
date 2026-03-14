import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:native_exif/native_exif.dart';
import 'package:gal/gal.dart';
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

  void _downloadPhoto(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading image...')));
    try {
      final response = await http.get(Uri.parse(photo.cloudinaryUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePrefix = photo.captureId ?? photo.id;
        final file = File('${directory.path}/$filePrefix.jpg');
        await file.writeAsBytes(response.bodyBytes);

        // Inject EXIF based on PhotoModel
        final exif = await Exif.fromPath(file.path);
        if (photo.imageHash != null) {
          await exif.writeAttribute('UserComment', photo.imageHash!);
        }
        
        // Re-inject the Capture ID and location
        Map<String, dynamic> locationDataMap = {};
        if (photo.captureId != null) {
          locationDataMap['captureId'] = photo.captureId;
        } else {
          locationDataMap['captureId'] = photo.id; // fallback
        }
        
        if (photo.latitude != null) {
          locationDataMap.addAll({
            'latitude': photo.latitude,
            'longitude': photo.longitude,
            'accuracy': photo.accuracy,
            'altitude': photo.altitude,
            'speed': photo.speed,
            'timestamp': photo.timestamp.toIso8601String(),
          });
        }
        await exif.writeAttribute('ImageDescription', jsonEncode(locationDataMap));
        await exif.close();

        // Save to gallery
        await Gal.putImage(file.path);
        await file.delete(); // cleanup temp file
        
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Gallery with verification data!')));
        }
      } else {
         if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to download image.')));
         }
      }
    } catch (e) {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
    }
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
