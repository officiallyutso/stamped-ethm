import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stamped/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/features/auth/auth_screen.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';
import 'package:stamped/features/workspace/widgets/project_selection_sheet.dart';
import 'package:stamped/features/workspace/workspace_dashboard_screen.dart';

class WorkspaceBanner extends StatelessWidget {
  const WorkspaceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, WorkspaceProvider>(
      builder: (context, authProvider, workspaceProvider, child) {
        final isLoggedIn = authProvider.isAuthenticated;
        final currentWorkspace = workspaceProvider.currentWorkspace;
        final currentProject = workspaceProvider.currentProject;
        
        return Container(
          width: double.infinity,
          color: AppColors.primaryBlue,
          // Remove padding from Container as InkWells will handle it
          child: Row(
            children: [
              // Left Half: Workspace
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (!isLoggedIn) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    } else {
                      // Navigate to Workspace Dashboard
                      // If there is no workspace selected, just show default or generic workspace view,
                      // but user requested to open Selected Team / Dashboard
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WorkspaceDashboardScreen()),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: AppColors.textBlue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            isLoggedIn 
                              ? (currentWorkspace?.name ?? "Your Workspace")
                              : 'Setup Team Workspace',
                            style: const TextStyle(
                              color: AppColors.textBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLoggedIn) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            LucideIcons.chevronDown,
                            color: AppColors.textBlue,
                            size: 16,
                          ),
                        ],
                        if (!isLoggedIn) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            LucideIcons.arrowRight,
                            color: AppColors.textBlue,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // Right Half: Project Selection
              if (isLoggedIn)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const ProjectSelectionSheet(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              currentProject?.name ?? "No Project",
                              style: const TextStyle(
                                color: AppColors.textBlue,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            LucideIcons.chevronDown,
                            color: AppColors.textBlue,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
