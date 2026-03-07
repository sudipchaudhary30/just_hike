import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/api/api_client.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:just_hike/models/guide.dart' as model;

final profileProvider = Provider<UserProfile>((ref) {
  return UserProfile(name: 'Name');
});

final guidesProvider = FutureProvider<List<model.Guide>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(ApiEndpoints.getAllGuides);

  if (response.statusCode != 200 && response.statusCode != 201) {
    return [];
  }

  final dynamic rawData = response.data;
  List<dynamic> data = <dynamic>[];

  if (rawData is List) {
    data = rawData;
  } else if (rawData is Map<String, dynamic>) {
    final dynamic directData = rawData['data'];
    final dynamic guidesField = rawData['guides'];

    if (directData is List) {
      data = directData;
    } else if (guidesField is List) {
      data = guidesField;
    } else if (directData is Map<String, dynamic>) {
      final dynamic nestedGuides =
          directData['guides'] ?? directData['items'] ?? directData['data'];
      if (nestedGuides is List) {
        data = nestedGuides;
      }
    }
  }

  return data
      .map((item) {
        if (item is Map<String, dynamic>) {
          final dynamic guideField = item['guide'];
          if (guideField is Map<String, dynamic>) {
            return <String, dynamic>{...guideField, ...item};
          }
          return item;
        }
        return null;
      })
      .whereType<Map<String, dynamic>>()
      .map(model.Guide.fromJson)
      .toList();
});

class UserProfile {
  final String name;
  UserProfile({required this.name});
}
