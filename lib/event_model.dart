class Event {
  final String id;
  final String title;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String organizer;
  final String imageUrl;
  final int capacity;
  final int registeredCount;
  final bool isOnline;
  final List<String> tags;

  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.organizer,
    required this.imageUrl,
    required this.capacity,
    required this.registeredCount,
    required this.isOnline,
    required this.tags,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      location: json['location'] ?? '',
      organizer: json['organizer'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      capacity: json['capacity'] ?? 0,
      registeredCount: json['registeredCount'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}