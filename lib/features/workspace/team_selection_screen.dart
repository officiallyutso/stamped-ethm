import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';
import 'package:stamped/core/theme/app_colors.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/core/theme/app_colors.dart';
import 'package:stamped/core/services/backend_api_service.dart';


class TeamSelectionScreen extends StatelessWidget {
  const TeamSelectionScreen({super.key});

  void _joinTeamDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join a Team'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Invite Code',
            hintText: 'Enter 6-character code',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final wp = Provider.of<WorkspaceProvider>(context, listen: false);
                
                final joinedWorkspace = await wp.workspaceService.joinWorkspace(code, auth.user!.uid);
                if (joinedWorkspace != null && context.mounted) {
                  // Auto-create user wallet in this workspace
                  try {
                    await BackendApiService().createUserWallet(
                      workspaceId: joinedWorkspace.id,
                      userId: auth.user!.uid,
                      displayName: auth.user!.displayName ?? auth.user!.email ?? 'User',
                    );
                    debugPrint('[INFO] User wallet created on join');
                  } catch (e) {
                    debugPrint('[WARN] User wallet creation failed: $e');
                  }

                  wp.setWorkspace(joinedWorkspace);
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close team selection
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid code or error joining.')));
                }
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _createTeamDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Your Team'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Team Name',
            hintText: 'e.g. Acme Corp',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final wp = Provider.of<WorkspaceProvider>(context, listen: false);
                
                final newWorkspace = await wp.workspaceService.createWorkspace(name, auth.user!.uid);
                
                // Auto-create BitGo wallet for the new workspace
                try {
                  await BackendApiService().createWorkspaceWallet(
                    workspaceId: newWorkspace.id,
                    workspaceName: newWorkspace.name,
                  );
                  debugPrint('[INFO] Workspace wallet created');
                } catch (e) {
                  debugPrint('[WARN] Workspace wallet creation failed: $e');
                }

                // Also create a user wallet for the owner in this workspace
                try {
                  await BackendApiService().createUserWallet(
                    workspaceId: newWorkspace.id,
                    userId: auth.user!.uid,
                    displayName: auth.user!.displayName ?? auth.user!.email ?? 'Owner',
                  );
                  debugPrint('[INFO] Owner user wallet created');
                } catch (e) {
                  debugPrint('[WARN] Owner user wallet creation failed: $e');
                }

                if (context.mounted) {
                  wp.setWorkspace(newWorkspace);
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close team selection
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WorkspaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Selected Team'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder(
        stream: wp.workspaceService.getUserWorkspaces(auth.user?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final workspaces = snapshot.data ?? [];
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // List existing workspaces
              ...workspaces.map((workspace) {
                final isSelected = wp.currentWorkspace?.id == workspace.id;
                final isOwner = auth.user?.uid == workspace.ownerId;
                
                return Card(
                  color: isSelected ? AppColors.primaryRed.withOpacity(0.4) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(workspace.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${workspace.memberIds.length} Members • Team Owner: ${isOwner ? "You" : "Other"}'),
                    trailing: isSelected ? const Icon(LucideIcons.checkCircle2, color: AppColors.textRed) : null,
                    onTap: () {
                      wp.setWorkspace(workspace);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'New Team',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(LucideIcons.plusCircle),
                title: const Text('Create your Team'),
                onTap: () => _createTeamDialog(context),
              ),
              ListTile(
                leading: const Icon(LucideIcons.logIn),
                title: const Text('Join a Team'),
                onTap: () => _joinTeamDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
