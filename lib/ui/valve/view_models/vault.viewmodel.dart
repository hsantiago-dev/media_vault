import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_vault/data/repositories/workspace.repository.dart';
import 'package:media_vault/domain/models/file-system-node.model.dart';
import 'package:media_vault/util/command.dart';
import 'package:media_vault/util/result.dart';

class VaultViewModel extends ChangeNotifier {
  late Command0 pickWorkspace;
  late Command1 selectDirectoryNode;
  late Command1 rollbackDirectoryNode;
  final WorkspaceRepository _workspaceRepository;

  VaultViewModel({
    required WorkspaceRepository workspaceRepository,
  }) : _workspaceRepository = workspaceRepository {
    pickWorkspace = Command0(_pickWorkspace);
    selectDirectoryNode = Command1((directoryNode) async {
      final result = await _selectDirectoryNode(directoryNode);
      return result;
    });
    rollbackDirectoryNode = Command1((directoryNode) async {
      final result = await _rollbackDirectoryNode(directoryNode);
      return result;
    });
  }

  DirectoryNode? _workspace;
  DirectoryNode? get workspace => _workspace;

  DirectoryNode? _selectedDirectoryNode;
  DirectoryNode? get selectedDirectoryNode => _selectedDirectoryNode;

  final List<DirectoryNode> _directoryStack = [];
  List<DirectoryNode> get directoryStack => _directoryStack;

  Future<Result<void>> _rollbackDirectoryNode(
      DirectoryNode? directoryNode) async {
    try {
      if (_directoryStack.isEmpty) {
        return Result.error(Exception("Não é possível voltar."));
      }

      if (directoryNode == null) {
        _selectedDirectoryNode = null;
        _directoryStack.clear();
        return Result.ok(null);
      }

      final index = _directoryStack.indexOf(directoryNode);

      _directoryStack.removeRange(index + 1, _directoryStack.length);
      _selectedDirectoryNode = directoryNode;

      return Result.ok(null);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _selectDirectoryNode(DirectoryNode directoryNode) async {
    try {
      _selectedDirectoryNode = directoryNode;
      _directoryStack.add(directoryNode);

      return Result.ok(null);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _pickWorkspace() async {
    try {
      final directoryPath = await _pickDirectory();
      // final directoryPath = 'D:\CURSINHO';
      if (directoryPath == null) {
        _selectedDirectoryNode = null;
        _directoryStack.clear();
        _workspace = null;
        return Result.ok(null);
      }

      final directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        return Result.error(Exception("Diretório inválido."));
      }

      final directoryNode = _convertDirectoryToNode(directory);
      updatePercentageConcluded(directoryNode);
      final result = await _workspaceRepository.saveWorkspace(directoryNode);

      switch (result) {
        case Ok<void>():
          _selectedDirectoryNode = null;
          _directoryStack.clear();
          _workspace = directoryNode;
          break;
        case Error<void>():
          return result;
      }

      return result;
    } finally {
      notifyListeners();
    }
  }

  Future<String?> _pickDirectory() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    return directoryPath;
  }

  DirectoryNode _convertDirectoryToNode(Directory directory) {
    // Criar o nó raiz para o diretório atual.
    final DirectoryNode node =
        DirectoryNode(directory.path.split(Platform.pathSeparator).last);

    // Iterar sobre os itens do diretório.
    final List<FileSystemEntity> entities = directory.listSync();
    bool isWatched = false;
    for (final entity in entities) {
      if (entity is Directory) {
        // Recursivamente adicionar subdiretórios.
        node.addChild(_convertDirectoryToNode(entity));
      } else if (entity is File) {
        // Adicionar arquivos diretamente.
        node.addChild(FileNode(entity.path.split(Platform.pathSeparator).last,
            entity.path, isWatched));
        isWatched = !isWatched;
      }
    }

    return node;
  }

  void updatePercentageConcluded(DirectoryNode directoryNode) {
    // Função interna para calcular a proporção de arquivos marcados
    int calculateAndSet(DirectoryNode dir) {
      int totalFiles = 0;
      int checkedFiles = 0;

      for (var child in dir.children) {
        if (child is FileNode) {
          totalFiles++;
          if (child.isChecked) {
            checkedFiles++;
          }
        } else if (child is DirectoryNode) {
          // Processa recursivamente e acumula
          int subFiles = calculateAndSet(child);
          totalFiles += subFiles;
          checkedFiles += (subFiles * child.percentageConcluded).toInt();
        }
      }

      // Evita divisão por zero e atualiza o atributo
      dir.percentageConcluded =
          totalFiles == 0 ? 0.0 : (checkedFiles / totalFiles);
      return totalFiles;
    }

    // Chama a função para o diretório inicial
    calculateAndSet(directoryNode);
  }
}
