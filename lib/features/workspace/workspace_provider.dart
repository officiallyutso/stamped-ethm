import 'package:flutter/material.dart';
import '../../core/models/workspace_model.dart';
import '../../core/models/project_model.dart';
import '../../core/services/workspace_service.dart';
import '../../core/services/backend_api_service.dart';

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
        
        // Auto-create workspace wallet if doesn't have one
        if (workspaces.first.walletId == null) {
          _ensureWalletExists(workspaces.first);
        }
        // Auto-create user wallet if doesn't have one
        _ensureUserWalletExists(workspaces.first, userId);
      } else {
        // If they don't have a workspace, create a default one
        final newWorkspace = await _workspaceService.createWorkspace("My Team Workspace", userId);
        setWorkspace(newWorkspace);
        _ensureWalletExists(newWorkspace);
        _ensureUserWalletExists(newWorkspace, userId);
      }
    } catch (e) {
      debugPrint("Error loading user workspace: $e");
    }
  }

  /// Creates a BitGo wallet for the workspace if it doesn't have one
  Future<void> _ensureWalletExists(WorkspaceModel workspace) async {
    try {
      await BackendApiService().createWorkspaceWallet(
        workspaceId: workspace.id,
        workspaceName: workspace.name,
      );
      debugPrint('[INFO] Wallet ensured for workspace: ${workspace.id}');
    } catch (e) {
      debugPrint('[WARN] Could not create wallet (backend may be offline): $e');
    }
  }

  /// Creates a BitGo wallet for the user in this workspace if they don't have one
  Future<void> _ensureUserWalletExists(WorkspaceModel workspace, String userId) async {
    try {
      await BackendApiService().createUserWallet(
        workspaceId: workspace.id,
        userId: userId,
        displayName: 'User',
      );
      debugPrint('[INFO] User wallet ensured for workspace: ${workspace.id}');
    } catch (e) {
      debugPrint('[WARN] Could not create user wallet (backend may be offline): $e');
    }
  }
  
  // Expose the service for UI to use
  WorkspaceService get workspaceService => _workspaceService;
}

