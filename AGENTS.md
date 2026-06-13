## Project Layout

- App: Output directory for distributable executables
- build: Intermediate directory for CMake build
- resources: Runtime assets consumed by Siv3D (Settings are available in `siv3d_resources()`)
- siv3d: Directory related to the Siv3D SDK. Normally, you do not need to edit with this in regular development.
  - sdk/<version>/include: Include directory for the Siv3D SDK. All APIs are declared here.
  - docs: Siv3D documentation. Basic usage and examples for API usage are written here. The Japanese and English editions contain the same content.
  - Siv3D.cmake: CMake plugin for building Siv3D projects
- src: Application source code
  - macOS
    - Info.plist: macOS app bundle metadata
  - Main.cpp: Entry point of the application
  - ...
- CMakeLists.txt: Project configuration for the Siv3D app
- CMakePresets.json: Single source of truth for configure / build / workflow presets
- README.md: Summary document for users
