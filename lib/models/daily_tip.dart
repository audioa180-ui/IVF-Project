class DailyTip {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category;

  DailyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
  });

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
