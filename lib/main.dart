import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_vault/data/repositories/file.repository.dart';
import 'package:media_vault/data/repositories/workspace.repository.dart';
import 'package:media_vault/routing/router.dart';
import 'package:media_vault/ui/@core/themes/theme.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  MediaKit.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => WorkspaceRepository(FileRepository())),
        Provider(create: (_) => FileRepository()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router(),
    );
  }
}
