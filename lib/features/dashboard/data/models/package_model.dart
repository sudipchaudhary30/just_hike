import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';

class PackageModel {
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
  final String? banner;
  final List<String>? highlights;
  final String difficulty;
  final String category;
  final DateTime? startDate;
  final DateTime? endDate;
  final int maxParticipants;
  final int currentParticipants;
  final bool isWishlisted;
  final String status;

  PackageModel({
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
    this.banner,
    this.highlights,
    required this.difficulty,
    required this.category,
    this.startDate,
    this.endDate,
    required this.maxParticipants,
    required this.currentParticipants,
    this.isWishlisted = false,
    required this.status,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rating: _calculateRating(json['difficulty']),
      reviewCount: 0,
      daysCount: json['durationDays'] ?? 0,
      nightsCount: (json['durationDays'] ?? 0) - 1,
      imageUrl: json['imageUrl'] ?? json['thumbnailUrl'],
      banner: json['imageUrl'] ?? json['thumbnailUrl'],
      highlights: [],
      difficulty: json['difficulty'] ?? 'moderate',
      category: 'trek',
      startDate: null,
      endDate: null,
      maxParticipants: json['maxGroupSize'] ?? 0,
      currentParticipants: 0,
      isWishlisted: false,
      status: json['isActive'] == true ? 'active' : 'inactive',
    );
  }

  static double _calculateRating(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return 4.2;
      case 'moderate':
        return 4.5;
      case 'difficult':
        return 4.8;
      default:
        return 4.5;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'daysCount': daysCount,
      'nightsCount': nightsCount,
      'imageUrl': imageUrl,
      'banner': banner,
      'highlights': highlights,
      'difficulty': difficulty,
      'category': category,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'isWishlisted': isWishlisted,
      'status': status,
    };
  }

  PackageEntity toEntity() {
    return PackageEntity(
      id: id,
      title: title,
      description: description,
      location: location,
      price: price,
      rating: rating,
      reviewCount: reviewCount,
      daysCount: daysCount,
      nightsCount: nightsCount,
      imageUrl: imageUrl,
      banner: banner,
      highlights: highlights,
      difficulty: difficulty,
      category: category,
      startDate: startDate,
      endDate: endDate,
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants,
      isWishlisted: isWishlisted,
      status: status,
    );
  }

  factory PackageModel.fromEntity(PackageEntity entity) {
    return PackageModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      location: entity.location,
      price: entity.price,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      daysCount: entity.daysCount,
      nightsCount: entity.nightsCount,
      imageUrl: entity.imageUrl,
      banner: entity.banner,
      highlights: entity.highlights,
      difficulty: entity.difficulty,
      category: entity.category,
      startDate: entity.startDate,
      endDate: entity.endDate,
      maxParticipants: entity.maxParticipants,
      currentParticipants: entity.currentParticipants,
      isWishlisted: entity.isWishlisted,
      status: entity.status,
    );
  }
}