class ProgressEntity {
  final int total;
  final int uploaded;

  const ProgressEntity(this.uploaded, this.total);

  factory ProgressEntity.fromJson(Map<String, dynamic> json) =>
      ProgressEntity(json['done'], json['total']);

  double get value => double.parse((uploaded / total).toStringAsFixed(2));

  ProgressEntity copyWith({int uploaded, int total}) =>
      ProgressEntity(uploaded ?? this.uploaded, total ?? this.total);
}
