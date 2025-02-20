class Ad {
  final String filename;
  final String type;
  final String base64;

  Ad({required this.filename, required this.type, required this.base64});

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      filename: json['filename'],
      type: json['type'],
      base64: json['base64'],
    );
  }
}
