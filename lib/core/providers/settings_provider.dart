import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf_tool/core/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app settings
class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;
  String get language => _settings.language;
  String get defaultQuality => _settings.defaultQuality;
  String get storageLocation => _settings.storageLocation;
  bool get showNotifications => _settings.showNotifications;
  bool get autoOpenFile => _settings.autoOpenFile;
  bool get saveHistory => _settings.saveHistory;
  List<String> get favoriteToolIds => _settings.favoriteToolIds;

  /// Toggle dark mode
  void toggleDarkMode() {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    notifyListeners();
    _saveSettings();
  }

  /// Set dark mode
  void setDarkMode(bool value) {
    if (_settings.isDarkMode != value) {
      _settings = _settings.copyWith(isDarkMode: value);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Set language
  void setLanguage(String language) {
    if (_settings.language != language) {
      _settings = _settings.copyWith(language: language);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Set default quality
  void setDefaultQuality(String quality) {
    if (_settings.defaultQuality != quality) {
      _settings = _settings.copyWith(defaultQuality: quality);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Set storage location
  void setStorageLocation(String location) {
    if (_settings.storageLocation != location) {
      _settings = _settings.copyWith(storageLocation: location);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Toggle notifications
  void toggleNotifications() {
    _settings = _settings.copyWith(showNotifications: !_settings.showNotifications);
    notifyListeners();
    _saveSettings();
  }

  /// Set notifications
  void setNotifications(bool value) {
    if (_settings.showNotifications != value) {
      _settings = _settings.copyWith(showNotifications: value);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Toggle auto open file
  void toggleAutoOpenFile() {
    _settings = _settings.copyWith(autoOpenFile: !_settings.autoOpenFile);
    notifyListeners();
    _saveSettings();
  }

  /// Set auto open file
  void setAutoOpenFile(bool value) {
    if (_settings.autoOpenFile != value) {
      _settings = _settings.copyWith(autoOpenFile: value);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Toggle save history
  void toggleSaveHistory() {
    _settings = _settings.copyWith(saveHistory: !_settings.saveHistory);
    notifyListeners();
    _saveSettings();
  }

  /// Set save history
  void setSaveHistory(bool value) {
    if (_settings.saveHistory != value) {
      _settings = _settings.copyWith(saveHistory: value);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Toggle favorite tool
  void toggleFavoriteTool(String toolId) {
    final favorites = List<String>.from(_settings.favoriteToolIds);
    if (favorites.contains(toolId)) {
      favorites.remove(toolId);
    } else {
      favorites.add(toolId);
    }
    _settings = _settings.copyWith(favoriteToolIds: favorites);
    notifyListeners();
    _saveSettings();
  }

  /// Check if a tool is favorite
  bool isFavorite(String toolId) {
    return _settings.favoriteToolIds.contains(toolId);
  }


  /// Reset settings to default
  void resetSettings() {
    _settings = const AppSettings();
    notifyListeners();
    _saveSettings();
  }

  /// Load settings from storage
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsStr = prefs.getString('app_settings');
      
      if (settingsStr != null) {
        final Map<String, dynamic> json = jsonDecode(settingsStr);
        _settings = AppSettings.fromJson(json);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load settings: $e');
      _settings = const AppSettings();
      notifyListeners();
    }
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', jsonEncode(_settings.toJson()));
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }

  /// Get theme mode based on settings
  ThemeMode get themeMode {
    return _settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
