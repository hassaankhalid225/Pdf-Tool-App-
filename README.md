# 📄 PDF Tools Pro

A premium, privacy-first, cross-platform Flutter application for converting and managing documents locally on your device. Powered by Material 3 design and built with a clean feature-first architecture.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS-E0E0E0?style=for-the-badge" alt="Platforms" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

---

## 🌟 Key Highlights

*   🛡️ **100% Privacy & Offline Processing**: Your files never leave your device. All document conversions run completely offline using native parsers and writers.
*   🎨 **Premium Material Design 3 UI**: Featuring a beautiful dark mode, modern card designs, vibrant gradients, and glassmorphism elements.
*   ⚡ **Fluid Navigation**: Built with an elegant `google_nav_bar` (GNav) bottom navigation system for smooth transition animations.
*   📁 **Local File Management**: Open, share, and save your converted files directly to your device's Downloads or Documents folders using native system dialogs.

---

## 📖 Table of Contents

- [Features](#-features)
  - [Conversions: From PDF](#conversions-from-pdf)
  - [Conversions: To PDF](#conversions-to-pdf)
  - [App Highlights](#app-highlights)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Project Architecture](#-project-architecture)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Clone & Run](#clone--run)
  - [Platform Configuration](#platform-configuration)
- [Usage Guide](#-usage-guide)
- [Known Limitations](#-known-limitations)
- [Building for Release](#-building-for-release)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🛠️ Features

### Conversions: From PDF

| Tool | Format | Notes |
|:---|:---:|:---|
| **PDF to Word** | `.docx` | Extracts structured text paragraphs and headers into Microsoft Word format. |
| **PDF to Excel** | `.xlsx` | Scans text structures and exports clean tabular data into spreadsheet rows. |
| **PDF to PowerPoint** | `.pptx` | Extracts document text and structures it slides-ready. |
| **PDF to Image** | `.png` | Renders and converts document pages to high-quality image format. |
| **PDF to Text** | `.txt` | Plain-text extraction for quick copying and lightweight storage. |
| **PDF to HTML** | `.html` | Generates a clean, readable web page wrapped in a modern CSS template. |
| **PDF to EPUB** | `.epub` | Exports text content to electronic publication format. |

### Conversions: To PDF

| Tool | Format | Notes |
|:---|:---:|:---|
| **Image to PDF** | `.jpg`, `.png`, `.webp`, `.bmp`, `.gif` | Converts single or multiple images into a unified PDF file (e.g. scanner mode). |
| **Word to PDF** | `.docx` | Parses formatting, text fonts, and writes a clean PDF file natively. |
| **Excel to PDF** | `.xlsx` | Conversions for spreadsheets to PDF format. |
| **PowerPoint to PDF** | `.pptx` | Exports presentation slides directly to document pages. |
| **Text to PDF** | `.txt` | Formats plain text files into clean, professional PDF documents. |
| **Merge PDF** | Multiple `.pdf` | Combines multiple PDF files into a single document in your chosen order. |

### App Highlights

*   **Integrated Search**: Instant filtering of all tools from the Home screen's hero section.
*   **Dedicated Favorites**: Fast access tab to bookmark and organize your most-used tools.
*   **Detailed Conversion Queue**: Batch process multiple files, monitor completion progress, and handle error retries in a unified UI.
*   **History Logs**: Seamlessly view and manage past converted files list. Clear logs with a single tap.
*   **Theme Options**: System, light, and dark theme support using customized Material 3 palettes.

---

## 📱 Screenshots

> Place your app screenshots inside [assets/screenshots/](file:///d:/Switch2itech/Flutter%20APps/pdf_tool/assets/screenshots/) and reference them below before publishing your repository.

<p align="center">
  <table align="center">
    <tr>
      <td align="center"><b>Home Screen</b></td>
      <td align="center"><b>Favorites Screen</b></td>
      <td align="center"><b>Conversion Queue</b></td>
    </tr>
    <tr>
      <td><img src="assets/screenshots/home.png" width="240" alt="Home Screen" /></td>
      <td><img src="assets/screenshots/favorites.png" width="240" alt="Favorites Screen" /></td>
      <td><img src="assets/screenshots/conversion.png" width="240" alt="Conversion Screen" /></td>
    </tr>
    <tr>
      <td align="center"><b>Files / History</b></td>
      <td align="center"><b>Settings / Theme</b></td>
      <td align="center"><b>Dark Mode</b></td>
    </tr>
    <tr>
      <td><img src="assets/screenshots/history.png" width="240" alt="History Screen" /></td>
      <td><img src="assets/screenshots/settings.png" width="240" alt="Settings Screen" /></td>
      <td><img src="assets/screenshots/dark_mode.png" width="240" alt="Dark Mode" /></td>
    </tr>
  </table>
</p>

---

## 💻 Tech Stack

| Component | Library / Package | Purpose |
|:---|:---|:---|
| **Core Framework** | [Flutter SDK](https://flutter.dev) | Cross-platform runtime & widgets |
| **State Management** | [Provider](https://pub.dev/packages/provider) | App navigation and conversion flow states |
| **PDF Processing** | [pdf](https://pub.dev/packages/pdf), [syncfusion_flutter_pdf](https://pub.dev/packages/syncfusion_flutter_pdf) | Creating, reading, merging, and writing PDFs |
| **Spreadsheets** | [syncfusion_flutter_xlsio](https://pub.dev/packages/syncfusion_flutter_xlsio) | Parsing Excel sheets and creating documents |
| **Storage & Preferences** | [shared_preferences](https://pub.dev/packages/shared_preferences) | Persistence of Favorites list, History logs, and settings |
| **File Management** | [file_picker](https://pub.dev/packages/file_picker), [path_provider](https://pub.dev/packages/path_provider) | Native storage read/write and file access |
| **Sharing** | [share_plus](https://pub.dev/packages/share_plus) | System sharing sheet integrations |
| **UI Components** | [google_nav_bar](https://pub.dev/packages/google_nav_bar), `shimmer` | Floating navigation, loading skeletons |

---

## 🏗️ Project Architecture

The project is structured following clean **Feature-First** guidelines:

```
lib/
├── main.dart                 # Application entry point
├── routes/
│   └── app_routes.dart       # Named route definitions & arguments handler
├── core/                     # Shared configurations and assets
│   ├── constants/            # Global theme colors, enums, strings, and tools catalog
│   ├── providers/            # Settings and navigation providers
│   ├── services/             # Native file access, permissions, and conversion engines
│   ├── theme/                # Custom Material 3 Light/Dark color themes
│   ├── utils/                # Screen responsiveness and grid layout calculators
│   └── widgets/              # Shared components (empty state widgets, skeletons)
└── features/                 # Modular application features
    ├── home/                 # Main grid categorizing tools, search, stats
    ├── favorites/            # Bookmark tools page displaying user's favorite tools
    ├── conversion/           # File selectors, convert status stepper, results screen
    ├── history/              # Local conversions log showing date, size, and type
    ├── settings/             # Dynamic appearance switcher, default directory selector
    ├── about/                # Application description, version, and credits
    └── main/                 # Navigation shell container hosting GNav and screens
```

---

## 🚀 Getting Started

### Prerequisites

*   **Flutter SDK**: `^3.10.3`
*   **Dart SDK**: `^3.0.0`
*   **Android Studio** (for Android build) / **Xcode** (for iOS/macOS builds)

### Clone & Run

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/hassaankhalid225/Pdf-Tool-App-.git
    cd Pdf-Tool-App-
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

### Platform Configuration

#### Android
The app utilizes `file_picker` and `path_provider` to read and write files. No extra runtime permission configuration is required for basic local storage operations on newer Android SDKs.

#### iOS
To build on iOS, add keys in `ios/Runner/Info.plist` for file picking support:
```xml
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UIFileSharingEnabled</key>
<true/>
```

---

## 💡 Usage Guide

1.  **Select a Tool**: Choose from categorized sections on the Home screen or search using the bar.
2.  **Upload Your Files**: Tap the upload dropzone to pick files from your device.
3.  **Queue Management**: If converting multiple files, tap **Add More** to queue them.
4.  **Process**: Tap **Convert Now** or **Convert All**. The status stepper will visual progress.
5.  **Save or Share**: Once finished, download the output to your local Downloads directory or tap **Share** to send it via other apps.
6.  **Access History**: Open the **Files** tab on the bottom bar to manage all past exports.

---

## ⚠️ Known Limitations

*   **File Size Limit**: By default, a maximum limit of **50 MB** per file is enforced in `ConversionService.maxFileSize` to prevent memory bottlenecks.
*   **Layout Preservation**: Advanced styles, fonts, and images in PDF to Word or Excel conversions are text-focused; complex formats may be simplified.
*   **PDF to Image**: Currently exports the **first page** of the selected PDF.

---

## 📦 Building for Release

Build production-ready, obfuscated release bundles for supported targets:

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Google Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Web
flutter build web --release
```

---

## 🤝 Contributing

We welcome community contributions!

1.  Fork the Project.
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the Branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## ❤️ Acknowledgments

*   The [Flutter Community](https://flutter.dev) for the amazing cross-platform tools.
*   [Syncfusion](https://www.syncfusion.com) for their robust office file-processing APIs.
*   All developers who contributed to the packages on [pub.dev](https://pub.dev).
