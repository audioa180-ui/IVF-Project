class Blog {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String category;
  final int readTime;
  final int likes;
  final String image;
  final String author;
  final DateTime date;

  Blog({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.category,
    required this.readTime,
    required this.likes,
    required this.image,
    required this.author,
    required this.date,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      excerpt: json['excerpt'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      readTime: json['readTime'] ?? 0,
      likes: json['likes'] ?? 0,
      image: json['image'] ?? '',
      author: json['author'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'category': category,
      'readTime': readTime,
      'likes': likes,
      'image': image,
      'author': author,
      'date': date.toIso8601String(),
    };
  }
}
