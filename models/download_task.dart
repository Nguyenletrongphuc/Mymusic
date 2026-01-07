enum DownloadStatus {
  queued,
  downloading,
  completed,
  failed,
}

class DownloadTask {
  final String id;
  final String url;
  final String fileName;
  DownloadStatus status;
  double progress;

  DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    this.status = DownloadStatus.queued,
    this.progress = 0,
  });
}
