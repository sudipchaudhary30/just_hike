class PackageEntity {
  final String id;
  final String title;
  final String description;
  final String location;
  final double price;
  final double rating;
  final int reviewCount;
  final int daysCount;
  final int nightsCount;
  final String? imageUrl;
  final String? thumbnailUrl;
  final List<String>? highlights;
  final String difficulty;
  final String category;
  final DateTime? startDate;
  final DateTime? endDate;
  final int maxParticipants;
  final int currentParticipants;
  final bool isWishlisted;
  final String status;
  final String? itinerary;
  final String? overview;

  PackageEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.daysCount,
    required this.nightsCount,
    this.imageUrl,
    this.thumbnailUrl,
    this.highlights,
    required this.difficulty,
    required this.category,
    this.startDate,
    this.endDate,
    required this.maxParticipants,
    required this.currentParticipants,
    this.isWishlisted = false,
    required this.status,
    this.itinerary,
    this.overview,
  });
}
