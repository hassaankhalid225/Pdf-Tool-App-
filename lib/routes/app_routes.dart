import 'package:flutter/material.dart';
import 'package:pdf_tool/features/conversion/presentation/screens/conversion_screen.dart';
import 'package:pdf_tool/features/settings/presentation/screens/settings_screen.dart';
import 'package:pdf_tool/features/about/presentation/screens/about_screen.dart';
import 'package:pdf_tool/features/history/presentation/screens/history_screen.dart';
import 'package:pdf_tool/features/main/presentation/screens/main_screen.dart';
import 'package:pdf_tool/features/home/presentation/screens/tool_category_screen.dart';
import 'package:pdf_tool/core/constants/enums.dart';
import 'package:pdf_tool/features/home/models/tool_model.dart';

/// App route names
class Routes {
  Routes._(); // Private constructor

  static const String home = '/';
  static const String conversion = '/conversion';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String history = '/history';
  static const String toolCategory = '/tool_category';
}

/// App routes configuration
class AppRoutes {
  AppRoutes._(); // Private constructor

  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.home: (context) => const MainScreen(),
    };
  }

  /// Generate route for dynamic navigation
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(
          builder: (context) => const MainScreen(),
          settings: settings,
        );

      case Routes.conversion:
        // Extract conversion type from arguments
        final args = settings.arguments as Map<String, dynamic>?;
        final conversionType = args?['conversionType'] as ConversionType?;
        
        if (conversionType == null) {
          return _errorRoute('Conversion type not specified');
        }

        return MaterialPageRoute(
          builder: (context) => ConversionScreen(
            conversionType: conversionType,
          ),
          settings: settings,
        );

      case Routes.settings:
        return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
          settings: settings,
        );

      case Routes.about:
        return MaterialPageRoute(
          builder: (context) => const AboutScreen(),
          settings: settings,
        );

      case Routes.history:
        return MaterialPageRoute(
          builder: (context) => const HistoryScreen(),
          settings: settings,
        );

      case Routes.toolCategory:
        final args = settings.arguments as Map<String, dynamic>?;
        final title = args?['title'] as String?;
        final tools = args?['tools'] as List<ToolModel>?;

        if (title == null || tools == null) {
          return _errorRoute('Category title or tools not specified');
        }

        return MaterialPageRoute(
          builder: (context) => ToolCategoryScreen(
            title: title,
            tools: tools,
          ),
          settings: settings,
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  /// Error route for undefined routes
  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }

  /// Navigate to conversion screen
  static Future<void> navigateToConversion(
    BuildContext context,
    ConversionType conversionType,
  ) async {
    await Navigator.pushNamed(
      context,
      Routes.conversion,
      arguments: {
        'conversionType': conversionType,
      },
    );
  }

  /// Navigate back
  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Navigate to home and clear stack
  static void navigateToHomeAndClear(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.home,
      (route) => false,
    );
  }
}
