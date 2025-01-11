import 'package:go_router/go_router.dart';
import 'package:media_vault/ui/home/view_models/home.viewmodel.dart';
import 'package:media_vault/ui/home/widgets/home.screen.dart';
import 'package:media_vault/ui/valve/view_models/vault.viewmodel.dart';
import 'package:media_vault/ui/valve/widgets/vault.screen.dart';
import 'package:provider/provider.dart';
import 'routes.dart';

GoRouter router() => GoRouter(
      initialLocation: Routes.valve,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            final viewModel = HomeViewModel();
            return HomeScreen(viewModel: viewModel);
          },
        ),
        GoRoute(
          path: Routes.valve,
          builder: (context, state) {
            final viewModel = VaultViewModel(
              workspaceRepository: context.read(),
              fileRepository: context.read(),
            );
            return VaultScreen(viewModel: viewModel);
          },
        ),
      ],
    );
