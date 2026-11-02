class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String tag;
  final String? actionButtonText;
  final String? bannerColorHex;
  final String? imageUrl;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    this.actionButtonText,
    this.bannerColorHex,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'tag': tag,
      'action_button_text': actionButtonText,
      'banner_color_hex': bannerColorHex,
      'image_url': imageUrl,
    };
  }

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      actionButtonText: json['action_button_text'] as String?,
      bannerColorHex: json['banner_color_hex'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

