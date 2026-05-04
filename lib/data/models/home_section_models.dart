import 'business_model.dart';

/// National brand section for home screen.
class NationalBrandSection {
  final String sectionTitle;
  final String sectionType;
  final String? sectionDescription;
  final List<BusinessModel> businesses;

  const NationalBrandSection({
    required this.sectionTitle,
    required this.sectionType,
    this.sectionDescription,
    this.businesses = const [],
  });

  factory NationalBrandSection.fromJson(Map<String, dynamic> json) {
    return NationalBrandSection(
      sectionTitle: json['section_title'] as String? ?? '',
      sectionType: json['section_type'] as String? ?? '',
      sectionDescription: json['section_description'] as String?,
      businesses: (json['businesses'] as List<dynamic>?)
              ?.map(
                  (e) => BusinessModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Dynamic section from home screen.
class DynamicSection {
  final String sectionName;
  final String sectionSlug;
  final int count;
  final List<BusinessModel> businesses;

  const DynamicSection({
    required this.sectionName,
    required this.sectionSlug,
    this.count = 0,
    this.businesses = const [],
  });

  factory DynamicSection.fromJson(Map<String, dynamic> json) {
    return DynamicSection(
      sectionName: json['section_name'] as String? ?? '',
      sectionSlug: json['section_slug'] as String? ?? '',
      count: json['count'] != null 
          ? int.tryParse(json['count'].toString()) ?? 0
          : 0,
      businesses: (json['businesses'] as List<dynamic>?)
              ?.map(
                  (e) => BusinessModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
