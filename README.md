# PDF Tools Pro

A professional Flutter application for PDF conversion and management with a beautiful, responsive UI and comprehensive file handling capabilities.

## Features

### From PDF Conversions
- ✅ **PDF to Word** - Convert PDF to editable Word documents
- ✅ **PDF to Excel** - Extract tables and data to Excel spreadsheets
- ✅ **PDF to PowerPoint** - Convert PDF to presentations
- ✅ **PDF to Image** - Convert PDF pages to high-quality images (PNG, JPG)
- ✅ **PDF to Text** - Extract all text content from PDFs
- ⚠️ **PDF to HTML** - Convert PDF to web pages (Coming Soon)
- ⚠️ **PDF to EPUB** - Convert PDF to eBook format (Coming Soon)

### To PDF Conversions
- ✅ **Image to PDF** - Convert images to PDF documents
- ✅ **Word to PDF** - Convert Word documents to PDF
- ⚠️ **Excel to PDF** - Convert spreadsheets to PDF (Coming Soon)
- ⚠️ **PowerPoint to PDF** - Convert presentations to PDF (Coming Soon)
- ✅ **Text to PDF** - Convert plain text files to PDF

### UI/UX Features
- 🎨 **Material Design 3** - Modern, beautiful interface
- 🌓 **Dark Mode** - Full dark theme support
- 📱 **Responsive Design** - Works on mobile, tablet, and desktop
- ⚡ **Smooth Animations** - Delightful user interactions
- 🎯 **Intuitive Navigation** - Easy-to-use interface
- 📊 **Progress Tracking** - Real-time conversion progress
- 💾 **File Management** - Download, share, and open converted files

## Screenshots

_Screenshots will be added here_

## Getting Started

### Prerequisites

- Flutter SDK (3.10.3 or higher)
- Dart SDK (3.10.3 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pdf_tool
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

#### iOS

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select images for conversion</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to capture images for conversion</string>
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/                              # Core functionality
│   ├── constants/                     # App constants
│   │   ├── app_colors.dart           # Color palette
│   │   ├── app_strings.dart          # String constants
│   │   ├── app_dimensions.dart       # Spacing & sizing
│   │   ├── enums.dart                # Enumerations
│   │   └── tools_data.dart           # Tool configurations
│   ├── theme/                         # Theme configuration
│   │   ├── app_theme.dart            # Light/Dark themes
│   │   └── text_styles.dart          # Typography
│   ├── utils/                         # Utility classes
│   │   └── responsive_helper.dart    # Responsive design
│   ├── widgets/                       # Reusable widgets
│   │   └── custom_button.dart        # Custom button
│   └── services/                      # Business logic
│       ├── conversion_service.dart   # Conversion operations
│       └── file_service.dart         # File operations
├── features/                          # Feature modules
│   ├── home/                          # Home feature
│   │   ├── models/                    # Data models
│   │   └── presentation/              # UI components
│   │       ├── screens/               # Screens
│   │       └── widgets/               # Feature widgets
│   └── conversion/                    # Conversion feature
│       ├── models/                    # Data models
│       ├── providers/                 # State management
│       └── presentation/              # UI components
│           ├── screens/               # Screens
│           └── widgets/               # Feature widgets
└── routes/                            # Navigation
    └── app_routes.dart               # Route configuration
```

## Architecture

This app follows **Clean Architecture** principles with:

- **Feature-based modular structure** - Each feature is self-contained
- **Provider for state management** - Simple and effective state handling
- **Separation of concerns** - UI, business logic, and data are separated
- **SOLID principles** - Maintainable and scalable code

## Dependencies

### Core
- `flutter` - Flutter SDK
- `provider` - State management

### File Handling
- `file_picker` - File selection
- `path_provider` - File paths
- `open_file` - Open files in external apps
- `share_plus` - Share files

### PDF Operations
- `pdf` - PDF creation
- `syncfusion_flutter_pdf` - Advanced PDF operations
- `printing` - PDF rendering

### Image Processing
- `image` - Image manipulation

### UI Components
- `flutter_svg` - SVG support
- `cached_network_image` - Image caching
- `shimmer` - Loading effects

### Utilities
- `intl` - Internationalization
- `uuid` - Unique IDs
- `permission_handler` - Permission management

## Usage

### Converting a File

1. **Select a Tool** - Choose from the home screen (e.g., "PDF to Word")
2. **Upload File** - Tap the upload area and select your file
3. **Convert** - Tap the "Convert" button
4. **Download/Share** - Once complete, download or share the converted file

### Supported File Formats

**Input Formats:**
- PDF: `.pdf`
- Images: `.jpg`, `.jpeg`, `.png`, `.webp`, `.bmp`
- Word: `.doc`, `.docx`
- Excel: `.xls`, `.xlsx`
- PowerPoint: `.ppt`, `.pptx`
- Text: `.txt`

**Output Formats:**
- PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX)
- Images (PNG, JPG), Text (TXT), HTML, EPUB

## Limitations

- **Maximum file size**: 50MB
- **PDF to Word**: Currently extracts text only (formatting not preserved)
- **PDF to Excel**: Currently extracts text only (table structure not preserved)
- **Some conversions**: Require additional implementation (marked as "Coming Soon")

## Future Enhancements

- [ ] Cloud conversion API integration for advanced conversions
- [ ] OCR support for scanned PDFs
- [ ] Batch conversion (multiple files)
- [ ] Cloud storage integration (Google Drive, Dropbox)
- [ ] PDF compression
- [ ] PDF merge/split
- [ ] PDF annotations
- [ ] Form filling
- [ ] Multi-language support
- [ ] Conversion history
- [ ] Favorite tools

## Building for Release

### Android

```bash
# APK
flutter build apk --release

# App Bundle (for Google Play)
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Email: support@pdftoolspro.com

## Acknowledgments

- Flutter team for the amazing framework
- Syncfusion for PDF processing capabilities
- All open-source contributors

---

**Made with ❤️ using Flutter**

Version: 1.0.0
Last Updated: January 2026
#   P d f - T o o l - A p p -  
 #   P d f - T o o l - A p p -  
 #   P d f - T o o l - A p p -  
 