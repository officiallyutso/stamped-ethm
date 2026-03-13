import 'package:flutter/material.dart';
import '../../core/models/workspace_model.dart';
import '../../core/models/project_model.dart';
import '../../core/services/workspace_service.dart';

class WorkspaceProvider with ChangeNotifier {
  final WorkspaceService _workspaceService = WorkspaceService();
  
  WorkspaceModel? _currentWorkspace;
  ProjectModel? _currentProject;
  
  WorkspaceModel? get currentWorkspace => _currentWorkspace;
  ProjectModel? get currentProject => _currentProject;
  
  void setWorkspace(WorkspaceModel workspace) {
    _currentWorkspace = workspace;
    _currentProject = null; // Reset project when workspace changes
    notifyListeners();
  }

  void setProject(ProjectModel? project) {
    _currentProject = project;
    notifyListeners();
  }

  void clearWorkspace() {
    _currentWorkspace = null;
    _currentProject = null;
    notifyListeners();
  }
  
  // New method: Load the user's workspace on login
  Future<void> loadUserWorkspace(String userId) async {
    try {
      final workspacesStream = _workspaceService.getUserWorkspaces(userId);
      final workspaces = await workspacesStream.first;
      
      if (workspaces.isNotEmpty) {
        // Just pick the first workspace they are part of for now
        setWorkspace(workspaces.first);
      } else {
        // If they don't have a workspace, create a default one
        final newWorkspace = await _workspaceService.createWorkspace("My Team Workspace", userId);
        setWorkspace(newWorkspace);
      }
    } catch (e) {
      debugPrint("Error loading user workspace: $e");
    }
  }
  
  // Expose the service for UI to use
  WorkspaceService get workspaceService => _workspaceService;
}
