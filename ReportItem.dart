enum ReportStatus {
  safe,
  alert,
}

class ReportItem {
  final String date;
  final String plate;
  final String? imagePath;
  final ReportStatus status;

  ReportItem({
    required this.date,
    required this.plate,
    this.imagePath,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'plate': plate,
    'imagePath': imagePath,
    'status': status.name,
  };

  factory ReportItem.fromJson(Map<String, dynamic> json) => ReportItem(
    date: json['date'],
    plate: json['plate'],
    imagePath: json['imagePath'],
    status: ReportStatus.values.byName(json['status']),
  );
}