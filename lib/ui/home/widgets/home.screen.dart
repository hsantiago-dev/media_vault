import 'package:flutter/material.dart';
import 'package:media_vault/ui/home/view_models/home.viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.resetCounter.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.resetCounter.removeListener(_onResult);
    widget.viewModel.resetCounter.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.resetCounter.removeListener(_onResult);
    super.dispose();
  }

  void _onResult() {
    if (widget.viewModel.resetCounter.completed) {
      widget.viewModel.incrementCounter.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contador resetado com sucesso.'),
        ),
      );
    }

    if (widget.viewModel.resetCounter.error) {
      widget.viewModel.resetCounter.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao resetar contador.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Flutter Architecture'),
      ),
      body: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    widget.viewModel.count.toString(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            );
          }),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 20,
        children: [
          FloatingActionButton(
            onPressed: () => widget.viewModel.resetCounter.execute(),
            tooltip: 'Reset',
            child: const Icon(Icons.refresh),
          ),
          FloatingActionButton(
            onPressed: () => widget.viewModel.incrementCounter.execute(),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
