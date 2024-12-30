import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_vault/data/repositories/workspace.repository.dart';
import 'package:media_vault/routing/router.dart';
import 'package:media_vault/ui/@core/themes/theme.dart';
import 'package:provider/provider.dart';

void main() {
  MediaKit.ensureInitialized();
  runApp(
    Provider(
      create: (context) => WorkspaceRepository(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router(),
    );
  }
}
