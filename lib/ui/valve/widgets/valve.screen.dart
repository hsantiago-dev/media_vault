import 'package:flutter/material.dart';
import 'package:media_vault/domain/models/file-system-node.model.dart';
import 'package:media_vault/ui/valve/view_models/valve.viewmodel.dart';

class ValveScreen extends StatefulWidget {
  const ValveScreen({super.key, required this.viewModel});

  final ValveViewModel viewModel;

  @override
  State<ValveScreen> createState() => _ValveScreenState();
}

class _ValveScreenState extends State<ValveScreen> {
  Widget _breadcumbDirectoryStack() {
    return Row(
      children: [
        for (var i = 0; i < widget.viewModel.directoryStack.length; i++)
          if (widget.viewModel.directoryStack[i] ==
              widget.viewModel.directoryStack.lastOrNull)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.chevron_right_rounded),
                ),
                Text(widget.viewModel.directoryStack[i].name),
              ],
            )
          else
            Row(
              children: [
                Icon(Icons.chevron_right_rounded),
                TextButton(
                  onPressed: () => widget.viewModel.rollbackDirectoryNode
                      .execute(widget.viewModel.directoryStack[i]),
                  child: Text(widget.viewModel.directoryStack[i].name),
                ),
              ],
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.home_rounded, size: 30),
                        onPressed: () => widget.viewModel.rollbackDirectoryNode
                            .execute(null),
                      ),
                      _breadcumbDirectoryStack(),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: widget.viewModel.pickWorkspace.execute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Text(widget.viewModel.workspace?.name ??
                            'Selecionar Workspace'),
                        Icon(
                          Icons.expand_more_rounded,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: widget.viewModel.pickWorkspace.execute,
                  child: Text(widget.viewModel.workspace?.name ??
                      'Selecionar Workspace'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                spacing: 10,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.grid_view_rounded,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, _) {
                    if (widget.viewModel.workspace == null) {
                      return Text('Sem diretório');
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          ...((widget.viewModel.selectedDirectoryNode == null)
                                  ? widget.viewModel.workspace!
                                  : widget.viewModel.selectedDirectoryNode!)
                              .children
                              .map((child) {
                            if (child is FileNode) {
                              return ListTile(
                                title: Text("Arquivo: ${child.name}"),
                                subtitle: Text("Caminho: ${child.path}"),
                                leading: Icon(Icons.insert_drive_file),
                              );
                            } else if (child is DirectoryNode) {
                              return ListTile(
                                title: Text(child.name),
                                leading: Icon(
                                  Icons.perm_media_rounded,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                                minTileHeight: 80,
                                onTap: () => widget
                                    .viewModel.selectDirectoryNode
                                    .execute(child),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                trailing: CircularCompletionIndicator(
                                  percentage: 0.5,
                                  size: 50,
                                  backgroundColor: Colors.grey[700],
                                ),
                              );
                            } else {
                              return SizedBox.shrink(); // Caso inesperado.
                            }
                          }),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularCompletionIndicator extends StatelessWidget {
  final double percentage;
  final double size;
  final Color color;
  final Color? backgroundColor;

  const CircularCompletionIndicator({
    super.key,
    required this.percentage,
    this.size = 100.0,
    this.color = Colors.teal,
    this.backgroundColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage,
            strokeWidth: 6,
            color: color,
            backgroundColor: backgroundColor,
          ),
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size * 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
