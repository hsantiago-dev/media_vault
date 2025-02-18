import 'package:go_router/go_router.dart';
import 'package:media_vault/ui/vault/view_models/vault.viewmodel.dart';
import 'package:media_vault/ui/vault/widgets/vault.screen.dart';
import 'package:provider/provider.dart';
import 'routes.dart';

GoRouter router() => GoRouter(
      initialLocation: Routes.vault,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: Routes.vault,
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
