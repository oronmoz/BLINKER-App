
class Media {
  final String mediaType;
  final List<String> url;
  final List<String> filePath;

  Media({
    required this.mediaType,
    required this.url,
    required this.filePath,
  });

  // Constructor to initialize with empty values
  Media.empty()
      : mediaType = '',
        url = const [],
        filePath = const [];


  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      mediaType: json['mediaType'],
      url: json['url'],
      filePath: json['filePath'],
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'mediaType': mediaType,
        'url': url,
        'textContent': filePath,
      };

}