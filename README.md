# PDF Tools Pro

A cross-platform Flutter app for converting and managing PDFs on your device. Convert between PDF, Office formats, images, and plain text with a Material Design 3 UI, dark mode, conversion history, and batch workflows.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Web-lightgrey" alt="Platforms" />
  <img src="https://img.shields.io/badge/license-Add%20LICENSE-lightgrey" alt="License" />
</p>

---

## Table of contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Getting started](#getting-started)
- [Usage](#usage)
- [Supported formats](#supported-formats)
- [Project structure](#project-structure)
- [Architecture](#architecture)
- [Tech stack](#tech-stack)
- [Known limitations](#known-limitations)
- [Building for release](#building-for-release)
- [Contributing](#contributing)
- [Third-party licenses](#third-party-licenses)
- [License](#license)

---

## Features

### Conversions — From PDF

| Tool | Output | Notes |
|------|--------|--------|
| PDF to Word | `.docx` | Text extraction; layout and images are not preserved |
| PDF to Excel | `.xlsx` | Text-based extraction; complex tables may not map cleanly |
| PDF to PowerPoint | `.pptx` | Text on a single slide |
| PDF to Image | `.png` | First page only; quality setting affects DPI |
| PDF to Text | `.txt` | Full text extraction |
| PDF to HTML | `.html` | Text wrapped in a simple HTML template |
| PDF to EPUB | `.epub` | Plain-text export (not a full EPUB package) |

### Conversions — To PDF

| Tool | Input | Notes |
|------|--------|--------|
| Image to PDF | JPG, PNG, WebP, BMP, GIF | One image per PDF page |
| Word to PDF | `.doc`, `.docx` | Parses DOCX text; legacy `.doc` support is limited |
| Excel to PDF | `.xls`, `.xlsx` | First sheet, up to ~50 rows (demo limit in parser) |
| PowerPoint to PDF | `.ppt`, `.pptx` | Slide text extraction |
| Text to PDF | `.txt` | Plain text to PDF |
| Merge PDF | Multiple `.pdf` | Combines files in selection order (batch mode) |

### App experience

- **On-device processing** — Files are converted locally; no upload to a cloud API
- **Material Design 3** — Light and dark themes
- **Responsive layout** — Phone, tablet, and desktop-friendly UI
- **Conversion history** — Recent jobs stored with `shared_preferences`
- **Batch conversion** — Convert multiple files or merge PDFs
- **Share & save** — Open, share, or save results via `share_plus` and the system file picker
- **Settings** — Theme, default quality, profile, help, and legal screens

---

## Screenshots

> Add screenshots to `docs/screenshots/` and reference them here before publishing.

```markdown
| Home | Conversion | History |
|------|------------|---------|
| ![Home](docs/screenshots/home.png) | ![Convert](docs/screenshots/convert.png) | ![History](docs/screenshots/history.png) |
```

---

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.10.3+** (Dart **3.10.3+**)
- Android Studio / Xcode (for mobile targets)
- A device, emulator, or desktop target enabled in Flutter

### Clone and run

```bash
git clone https://github.com/hassaankhalid225/Pdf-Tool-App-.git
cd Pdf-Tool-App-
flutter pub get
flutter run
```

### Platform notes

| Platform | Notes |
|----------|--------|
| **Android** | Storage/photo permissions are requested at runtime via `permission_handler` (API 33+ uses photos/videos; older APIs use storage). |
| **iOS** | Add usage descriptions to `ios/Runner/Info.plist` if you enable camera or photo library access. |
| **Desktop / Web** | Supported by Flutter; file picking uses `file_picker` per platform. |

Verify your toolchain:

```bash
flutter doctor
```

---

## Usage

1. Open the app and pick a tool from **Home** (e.g. **PDF to Word**).
2. Tap the upload area and select a file (max **50 MB**).
3. Tap **Convert Now** for a single file, or **Add More** → **Convert All** for batch / merge.
4. When finished, **download**, **share**, or **open** the output from the result screen.
5. View past jobs under **Files** (history tab).

**Merge PDF:** Select multiple PDFs, then use **Convert All** in batch mode.

---

## Supported formats

**Input**

| Category | Extensions |
|----------|------------|
| PDF | `.pdf` |
| Images | `.jpg`, `.jpeg`, `.png`, `.webp`, `.bmp`, `.gif` |
| Word | `.doc`, `.docx` |
| Excel | `.xls`, `.xlsx` |
| PowerPoint | `.ppt`, `.pptx` |
| Text | `.txt` |

**Output**

`.pdf`, `.docx`, `.xlsx`, `.pptx`, `.png`, `.txt`, `.html`, `.epub` (see [limitations](#known-limitations))

---

## Project structure

```
lib/
├── main.dart
├── routes/
│   └── app_routes.dart
├── core/
│   ├── constants/          # Colors, strings, tools catalog, enums
│   ├── models/
│   ├── providers/          # Settings, navigation
│   ├── services/           # Conversion, files, permissions
│   ├── theme/
│   ├── utils/
│   └── widgets/
└── features/
    ├── home/               # Tool grid and categories
    ├── conversion/         # Conversion flow, provider, UI
    ├── history/            # Conversion history
    ├── settings/           # Theme, profile, legal, subscription UI
    ├── about/
    └── main/               # Bottom navigation shell
```

---

## Architecture

- **Feature-first folders** — UI, models, and providers grouped by feature
- **Provider** (`provider`) for app and conversion state
- **Services** — `ConversionService`, `FileService`, and `PermissionService` separate business logic from widgets
- **Declarative routing** — Named routes in `app_routes.dart`

Conversion flow: `ConversionScreen` → `ConversionProvider` → `ConversionService` → output file on disk.

---

## Tech stack

| Area | Packages |
|------|----------|
| State | `provider` |
| PDF | `pdf`, `syncfusion_flutter_pdf`, `printing` |
| Office | `syncfusion_flutter_xlsio`, `archive`, `xml` |
| Files | `file_picker`, `path_provider`, `open_file`, `share_plus` |
| Images | `image` |
| Permissions | `permission_handler`, `device_info_plus` |
| Storage | `shared_preferences` |
| UI | Material 3, `shimmer`, `flutter_svg`, `cached_network_image` |

---

## Known limitations

- **Max file size:** 50 MB (`ConversionService.maxFileSize`).
- **PDF to Image:** Only the **first page** is exported.
- **Layout fidelity:** PDF → Word/Excel/PowerPoint and Office → PDF conversions are **text-oriented**; fonts, images, and complex layouts are not fully preserved.
- **PDF to EPUB:** Outputs extracted text, not a standards-compliant EPUB ebook.
- **Single-file vs batch:** `convertFile()` wires a subset of tools; tools such as **PDF to PowerPoint**, **PDF to HTML**, **Excel to PDF**, and **Merge PDF** rely on **batch** (`convertBatch()` / **Convert All**). Contributors can unify both code paths in `conversion_provider.dart`.
- **History:** Metadata is stored locally; output files may be cleared when the OS cleans temp storage.

---

## Building for release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (on macOS)
flutter build ios --release

# Windows / macOS / Linux / Web
flutter build windows --release
flutter build macos --release
flutter build linux --release
flutter build web --release
```

---

## Contributing

Contributions are welcome.

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit your changes with a clear message
4. Push and open a Pull Request against `main`

Please keep PRs focused and run `flutter analyze` and `flutter test` before submitting.

---

## Third-party licenses

This project uses open-source packages from [pub.dev](https://pub.dev) and **Syncfusion** Flutter packages (`syncfusion_flutter_pdf`, `syncfusion_flutter_xlsio`). Syncfusion components require a [valid license](https://www.syncfusion.com/sales/communitylicense) for commercial use. Review each dependency’s license before distributing your own build.

---

## License

No `LICENSE` file is included yet. If you plan to open-source this repo, add a license file (for example [MIT](https://choosealicense.com/licenses/mit/)) and update the badge above.

---

## Acknowledgments

- [Flutter](https://flutter.dev) team
- [Syncfusion](https://www.syncfusion.com/flutter-widgets) for PDF and Excel APIs
- All contributors and package authors on pub.dev

---

<p align="center">
  <strong>PDF Tools Pro</strong> · v1.0.0 · Built with Flutter
</p>
