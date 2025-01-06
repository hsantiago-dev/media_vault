import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_vault/data/repositories/workspace.repository.dart';
import 'package:media_vault/domain/models/file-system-node.model.dart';
import 'package:media_vault/domain/models/workspace.model.dart';
import 'package:media_vault/util/command.dart';
import 'package:media_vault/util/result.dart';

class VaultViewModel extends ChangeNotifier {
  late Command0 saveNewWorkspace;
  late Command1 selectWorkspace;
  late Command1 selectDirectoryNode;
  late Command1 rollbackDirectoryNode;
  final WorkspaceRepository _workspaceRepository;

  VaultViewModel({
    required WorkspaceRepository workspaceRepository,
  }) : _workspaceRepository = workspaceRepository {
    saveNewWorkspace = Command0(_saveNewWorkspace);
    selectWorkspace = Command1((id) async {
      final result = await _selectWorkspace(id);
      return result;
    });
    selectDirectoryNode = Command1((directoryNode) async {
      final result = await _selectDirectoryNode(directoryNode);
      return result;
    });
    rollbackDirectoryNode = Command1((directoryNode) async {
      final result = await _rollbackDirectoryNode(directoryNode);
      return result;
    });

    _getWorkspaces();
  }

  Workspace? _workspace;
  Workspace? get workspace => _workspace;

  List<Workspace> _workspaces = [];
  List<Workspace> get workspaces => _workspaces;

  DirectoryNode? _selectedDirectoryNode;
  DirectoryNode? get selectedDirectoryNode => _selectedDirectoryNode;

  final List<DirectoryNode> _directoryStack = [];
  List<DirectoryNode> get directoryStack => _directoryStack;

  Future<Result<void>> _getWorkspaces() async {
    try {
      final result = await _workspaceRepository.getWorkspaces();
      switch (result) {
        case Ok<List<Workspace>>():
          _workspaces = result.value;
          break;
        case Error():
          return result;
      }

      return result;
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _selectWorkspace(int id) async {
    final result = await _workspaceRepository.getWorkspace(id);
    return _pickWorkspace(result);
  }

  Future<Result<void>> _saveNewWorkspace() async {
    final directoryPath = await _pickDirectory();
    // final directoryPath = 'D:\CURSINHO';
    if (directoryPath == null) {
      _selectedDirectoryNode = null;
      _directoryStack.clear();
      _workspace = null;
      return Result.ok(null);
    }

    final name = directoryPath.split('\\').last;

    final workspace = Workspace.newWorkspace(name: name, path: directoryPath);
    final result = await _workspaceRepository.saveWorkspace(workspace);

    _getWorkspaces();
    return _pickWorkspace(result);
  }

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

  Future<Result<void>> _pickWorkspace(Result<Workspace> result) async {
    try {
      switch (result) {
        case Ok<Workspace>():
          _selectedDirectoryNode = null;
          _directoryStack.clear();
          _workspace = result.value;
          break;
        case Error():
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
}
