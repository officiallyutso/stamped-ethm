import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stamped/features/camera/camera_provider.dart';
import 'package:stamped/features/camera/camera_screen.dart';
import 'package:stamped/features/auth/auth_provider.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stamped/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: \$e");
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProxyProvider<AuthProvider, WorkspaceProvider>(
          create: (_) => WorkspaceProvider(),
          update: (context, authProvider, previousWorkspaceProvider) {
            // When auth changes, tell the workspace provider
            if (previousWorkspaceProvider != null) {
              if (authProvider.isAuthenticated) {
                // We only want to load it initially if it hasn't been loaded
                // To avoid reloading on every extraneous notifyListeners() from AuthProvider
                if (previousWorkspaceProvider.currentWorkspace == null) {
                  previousWorkspaceProvider.loadUserWorkspace(authProvider.user!.uid);
                }
              } else {
                previousWorkspaceProvider.clearWorkspace();
              }
            }
            return previousWorkspaceProvider ?? WorkspaceProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Stamped',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: const CameraScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

