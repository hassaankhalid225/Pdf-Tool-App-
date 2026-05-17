/// App settings model
class AppSettings {
  final bool isDarkMode;
  final String language;
  final String defaultQuality;
  final String storageLocation;
  final bool showNotifications;
  final bool autoOpenFile;
  final bool saveHistory;
  final List<String> favoriteToolIds;

  const AppSettings({
    this.isDarkMode = false,
    this.language = 'en',
    this.defaultQuality = 'high',
    this.storageLocation = 'downloads',
    this.showNotifications = true,
    this.autoOpenFile = false,
    this.saveHistory = true,
    this.favoriteToolIds = const [],
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? language,
    String? defaultQuality,
    String? storageLocation,
    bool? showNotifications,
    bool? autoOpenFile,
    bool? saveHistory,
    List<String>? favoriteToolIds,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      defaultQuality: defaultQuality ?? this.defaultQuality,
      storageLocation: storageLocation ?? this.storageLocation,
      showNotifications: showNotifications ?? this.showNotifications,
      autoOpenFile: autoOpenFile ?? this.autoOpenFile,
      saveHistory: saveHistory ?? this.saveHistory,
      favoriteToolIds: favoriteToolIds ?? this.favoriteToolIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'language': language,
      'defaultQuality': defaultQuality,
      'storageLocation': storageLocation,
      'showNotifications': showNotifications,
      'autoOpenFile': autoOpenFile,
      'saveHistory': saveHistory,
      'favoriteToolIds': favoriteToolIds,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      language: json['language'] as String? ?? 'en',
      defaultQuality: json['defaultQuality'] as String? ?? 'high',
      storageLocation: json['storageLocation'] as String? ?? 'downloads',
      showNotifications: json['showNotifications'] as bool? ?? true,
      autoOpenFile: json['autoOpenFile'] as bool? ?? false,
      saveHistory: json['saveHistory'] as bool? ?? true,
      favoriteToolIds: List<String>.from(json['favoriteToolIds'] as List? ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppSettings &&
        other.isDarkMode == isDarkMode &&
        other.language == language &&
        other.defaultQuality == defaultQuality &&
        other.storageLocation == storageLocation &&
        other.showNotifications == showNotifications &&
        other.autoOpenFile == autoOpenFile &&
        other.saveHistory == saveHistory &&
        _listEquals(other.favoriteToolIds, favoriteToolIds);
  }

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return isDarkMode.hashCode ^
        language.hashCode ^
        defaultQuality.hashCode ^
        storageLocation.hashCode ^
        showNotifications.hashCode ^
        autoOpenFile.hashCode ^
        saveHistory.hashCode ^
        favoriteToolIds.hashCode;
  }

  @override
  String toString() {
    return 'AppSettings(isDarkMode: $isDarkMode, language: $language, defaultQuality: $defaultQuality)';
  }
}
