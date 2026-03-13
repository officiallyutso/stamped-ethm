import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/core/models/project_model.dart';

class ProjectSelectionSheet extends StatefulWidget {
  const ProjectSelectionSheet({super.key});

  @override
  State<ProjectSelectionSheet> createState() => _ProjectSelectionSheetState();
}



class _ProjectSelectionSheetState extends State<ProjectSelectionSheet> {
  final TextEditingController _projectNameController = TextEditingController();

  Future<void> _createProject(BuildContext context) async {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);
    final workspace = workspaceProvider.currentWorkspace;
    if (workspace == null) return;

    final name = _projectNameController.text.trim();
    if (name.isEmpty) return;

    try {
      final project = await workspaceProvider.workspaceService.createProject(
        workspace.id,
        name,
      );
      workspaceProvider.setProject(project);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating project: $e')));
    }
  }

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _projectNameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'e.g. Site Survey',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); 
                _createProject(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(context);
    final workspace = workspaceProvider.currentWorkspace;

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Project',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(LucideIcons.folderX),
            title: const Text('No Project'),
            onTap: () {
              workspaceProvider.setProject(null);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.plusCircle),
            title: const Text('Create Project'),
            onTap: () {
              // Open create dialog
              _showCreateProjectDialog(context);
            },
          ),
          const Divider(),
          if (workspace != null)
            Expanded(
              child: StreamBuilder<List<ProjectModel>>(
                stream: workspaceProvider.workspaceService.getWorkspaceProjects(workspace.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  final projects = snapshot.data ?? [];
                  
                  if (projects.isEmpty) {
                    return const Center(
                      child: Text('No projects found in this workspace.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ListTile(
                        leading: const Icon(LucideIcons.folder),
                        title: Text(project.name),
                        onTap: () {
                          workspaceProvider.setProject(project);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          if (workspace == null)
            const Expanded(
              child: Center(
                child: Text('Please select a workspace first.'),
              ),
            )
        ],
      ),
    );
  }
}
