import 'package:go_router/go_router.dart';
import 'package:media_vault/ui/home/view_models/home.viewmodel.dart';
import 'package:media_vault/ui/home/widgets/home.screen.dart';
import 'routes.dart';

GoRouter router() => GoRouter(
      initialLocation: Routes.home,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            final viewModel = HomeViewModel();
            return HomeScreen(viewModel: viewModel);
          },
          routes: [],
        ),
      ],
    );
