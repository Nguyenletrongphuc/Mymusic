import 'package:flutter/material.dart';
import '../models/download_task.dart';

class DownloadProvider extends ChangeNotifier {
  final List<DownloadTask> _tasks = [];

  List<DownloadTask> get tasks => _tasks;

  void addTask(DownloadTask task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateStatus(String id, DownloadStatus status) {
    final task = _tasks.firstWhere((e) => e.id == id);
    task.status = status;
    notifyListeners();
  }

  void updateProgress(String id, double progress) {
    final task = _tasks.firstWhere((e) => e.id == id);
    task.progress = progress;
    notifyListeners();
  }
}
