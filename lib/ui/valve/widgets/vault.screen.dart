import 'package:flutter/material.dart';
import 'package:media_vault/domain/models/file-system-node.model.dart';
import 'package:media_vault/domain/models/workspace.model.dart';
import 'package:media_vault/ui/@core/themes/colors.dart';
import 'package:media_vault/ui/valve/view_models/vault.viewmodel.dart';
import 'package:media_vault/ui/valve/widgets/dialog-video.widget.dart';
import 'package:popover/popover.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key, required this.viewModel});

  final VaultViewModel viewModel;

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  Widget _breadcumbDirectoryStack() {
    return Row(
      children: [
        for (var i = 0; i < widget.viewModel.directoryStack.length; i++)
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

  void showVideoModal(
      BuildContext context, String videoName, String videoPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogVideoWidget(
          title: videoName,
          videoPath: videoPath,
        );
      },
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
                    spacing: 30,
                    children: [
                      InkWell(
                        onTap: () => widget.viewModel.rollbackDirectoryNode
                            .execute(null),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 50,
                        ),
                      ),
                      _breadcumbDirectoryStack(),
                    ],
                  ),
                  PopoverWorkspace(
                    workspace: widget.viewModel.workspace,
                    workspaces: widget.viewModel.workspaces,
                    onSelectWorkspace: (int id) => {
                      widget.viewModel.selectWorkspace.execute(id),
                    },
                    saveNewWorkspace: widget.viewModel.saveNewWorkspace.execute,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 30,
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
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sentiment_very_satisfied_rounded,
                            size: 85,
                            color: AppColors.grey2,
                          ),
                          Text(
                            'Selecione um diretório para começar.',
                            style: TextStyle(
                              color: AppColors.grey2,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        spacing: 10,
                        children: [
                          ...((widget.viewModel.selectedDirectoryNode == null)
                                  ? widget.viewModel.workspace!.workspaceNode!
                                  : widget.viewModel.selectedDirectoryNode!)
                              .children
                              .map((child) {
                            if (child is FileNode) {
                              return ListTile(
                                key: ValueKey(child.name),
                                leading: Icon(
                                  Icons.play_circle_rounded,
                                  size: 40,
                                ),
                                titleTextStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                title: Text(child.name),
                                subtitle: Text(
                                  child.path,
                                  style: TextStyle(
                                    color: AppColors.grey3,
                                    fontSize: 12,
                                  ),
                                ),
                                minTileHeight: 80,
                                onTap: () => showVideoModal(
                                    context, child.name, child.path),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                trailing: (child.isChecked)
                                    ? Icon(
                                        Icons.task_alt_rounded,
                                        size: 40,
                                        color: AppColors.green1,
                                      )
                                    : Icon(
                                        Icons.radio_button_off_rounded,
                                        size: 40,
                                      ),
                              );
                            } else if (child is DirectoryNode) {
                              return ListTile(
                                key: ValueKey(child.name),
                                leading: Icon(
                                  Icons.folder_rounded,
                                  size: 30,
                                  color: Colors.grey[600],
                                ),
                                titleTextStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                title: Text(child.name),
                                minTileHeight: 80,
                                onTap: () => widget
                                    .viewModel.selectDirectoryNode
                                    .execute(child),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                trailing: CircularCompletionIndicator(
                                  percentage: child.percentageConcluded,
                                  size: 40,
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

class PopoverWorkspace extends StatelessWidget {
  const PopoverWorkspace({
    super.key,
    required this.workspace,
    required this.workspaces,
    required this.onSelectWorkspace,
    required this.saveNewWorkspace,
  });

  final Workspace? workspace;
  final List<Workspace> workspaces;
  final Function(int) onSelectWorkspace;
  final Function() saveNewWorkspace;

  double calculateDxOffset(BuildContext context, double popoverWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth - popoverWidth - 20;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: AppColors.grey2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            Image.asset(
              'assets/planet.png',
              width: 30,
            ),
            Text(workspace?.name ?? 'Selecionar Workspace'),
            Icon(
              Icons.expand_more_rounded,
              size: 30,
            ),
          ],
        ),
      ),
      onTap: () {
        showPopover(
          context: context,
          backgroundColor: AppColors.blackTransparent,
          bodyBuilder: (context) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      bottom: 10,
                      left: 10,
                      right: 10,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        saveNewWorkspace();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded),
                          Text(
                            'Adicionar workspace',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.white1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...workspaces.map((workspace) {
                    return ListTile(
                      leading: Image.asset(
                        'assets/planet.png',
                        width: 30,
                      ),
                      title: Text(workspace.name),
                      subtitle: Text(workspace.path),
                      subtitleTextStyle: TextStyle(
                        color: AppColors.grey3,
                        fontSize: 14,
                      ),
                      onTap: () {
                        onSelectWorkspace(workspace.id);
                        Navigator.of(context).pop();
                      },
                    );
                  }),
                ],
              ),
            );
          },
          direction: PopoverDirection.bottom,
          width: 340,
          arrowHeight: 15,
          arrowWidth: 0,
        );
      },
    );
  }
}

class CircularCompletionIndicator extends StatelessWidget {
  final double percentage;
  final double size;
  final Color? backgroundColor;

  const CircularCompletionIndicator({
    super.key,
    required this.percentage,
    this.size = 100.0,
    this.backgroundColor = Colors.grey,
  });

  Color getColor(double percentage) {
    if (percentage < 0.5) {
      return AppColors.yellow1;
    } else if (percentage < 0.8) {
      return AppColors.blue1;
    } else {
      return AppColors.green1;
    }
  }

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
            strokeWidth: 4,
            color: getColor(percentage),
            backgroundColor: backgroundColor,
          ),
          Text(
            '${(percentage * 100).toInt()}',
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
