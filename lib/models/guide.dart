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
    String? pickString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    List<String>? parseLanguages(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String && value.trim().isNotEmpty) {
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return null;
    }

    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final merged = <String, dynamic>{...userMap, ...json};

    return Guide(
      name:
          pickString(['name', 'fullName', 'title', 'username']) ??
          (merged['name'] as String?),
      email: (merged['email'] as String?) ?? pickString(['email']),
      phoneNumber: pickString(['phoneNumber', 'phone', 'mobile']),
      bio: pickString(['bio', 'about', 'description', 'overview']),
      experienceYears:
          parseInt(merged['experienceYears']) ?? parseInt(merged['experience']),
      languages: parseLanguages(merged['languages']),
      imageUrl: pickString([
        'imageUrl',
        'profilePicture',
        'profileImage',
        'avatar',
        'photo',
        'image',
        'thumbnailUrl',
      ]),
      createdAt: merged['createdAt'] != null
          ? DateTime.tryParse(merged['createdAt'].toString())
          : null,
      updatedAt: merged['updatedAt'] != null
          ? DateTime.tryParse(merged['updatedAt'].toString())
          : null,
    );
  }
}
