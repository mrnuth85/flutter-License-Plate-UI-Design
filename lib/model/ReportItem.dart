  enum ReportStatus {
    safe,
    alert,
  }

  class ReportItem {
    final String date;
    final String plate;
    final String? imagePath;
    final ReportStatus status;
    final String? plateImagePath;

    ReportItem({
      required this.date,
      required this.plate,
      this.imagePath,
      this.plateImagePath,
      required this.status,
    });

    Map<String, dynamic> toJson() => {
      'date': date,
      'plate': plate,
      'imagePath': imagePath,
      'status': status.name,
      'plateImagePath': plateImagePath,
    };

    factory ReportItem.fromJson(Map<String, dynamic> json) => ReportItem(
      date: json['date'],
      plate: json['plate'],
      imagePath: json['imagePath'],
      plateImagePath: json['plateImagePath'],
      status: ReportStatus.values.byName(json['status']),
    );
  }