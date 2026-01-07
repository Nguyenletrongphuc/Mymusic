import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../models/download_task.dart';
import '../providers/download_provider.dart';
import '../services/download_service.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Column(
      children: [
        const SizedBox(height: 120),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Nhập link tải (YouTube, Facebook...)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  if (controller.text.isEmpty) return;

                  final task = DownloadTask(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    url: controller.text,
                    fileName:
                        'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
                  );

                  final provider = context.read<DownloadProvider>();
                  provider.addTask(task);

                  // start download immediately
                  provider.updateStatus(task.id, DownloadStatus.downloading);

                  controller.clear();

                  try {
                    await DownloadService.downloadAudio(
                      task.url,
                      fileName: task.fileName,
                      onProgress: (p) => provider.updateProgress(task.id, p),
                    );

                    provider.updateStatus(task.id, DownloadStatus.completed);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tải về thành công')),
                      );
                    }
                  } catch (e, stack) {
                    debugPrint('DOWNLOAD ERROR (UI): $e');
                    debugPrint(stack.toString());

                    provider.updateStatus(task.id, DownloadStatus.failed);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tải thất bại: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        const Text('Nhập link vào đây', style: TextStyle(color: Colors.grey)),

        const Divider(),

        Expanded(
          child: Consumer<DownloadProvider>(
            builder: (context, provider, _) {
              if (provider.tasks.isEmpty) {
                return const Center(child: Text('Chưa có file nào đang tải'));
              }

              return ListView.builder(
                itemCount: provider.tasks.length,
                itemBuilder: (context, index) {
                  final task = provider.tasks[index];

                  return ListTile(
                    title: Text(
                      task.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: task.status == DownloadStatus.completed
                              ? 1
                              : task.progress,
                        ),
                        const SizedBox(height: 4),
                        Text(_statusText(task.status)),
                      ],
                    ),
                    trailing: _buildActionIcon(task),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _statusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return 'Đang tải...';
      case DownloadStatus.completed:
        return 'Hoàn tất';
      case DownloadStatus.failed:
        return 'Lỗi';
      case DownloadStatus.queued:
        return 'Đang chờ';
    }
  }

  Widget _buildActionIcon(DownloadTask task) {
    switch (task.status) {
      case DownloadStatus.downloading:
        return const Icon(Icons.downloading);
      case DownloadStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case DownloadStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const SizedBox();
    }
  }
}
