class UploadcareProgress {
  final int total;
  final int uploaded;

  const UploadcareProgress({
    this.total,
    this.uploaded,
  });

  factory UploadcareProgress.fromJson(Map<String, dynamic> json) =>
      UploadcareProgress(total: json['total'], uploaded: json['done']);

  double get progress => uploaded / total;

  int get progressPercent => (progress * 100).ceil();
}
