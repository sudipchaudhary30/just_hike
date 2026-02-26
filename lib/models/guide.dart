class Guide {
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? bio;
  final int? experienceYears;
  final List<String>? languages;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Guide({
    this.name,
    this.email,
    this.phoneNumber,
    this.bio,
    this.experienceYears,
    this.languages,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  // Example: fromJson factory if you use API responses
  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      bio: json['bio'],
      experienceYears: json['experienceYears'],
      languages: (json['languages'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}
