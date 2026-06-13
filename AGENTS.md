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

## Siv3D Coding Rule

### Program structure

- Include only `<Siv3D.hpp>`; standard library headers are already included through it
- Entry point is `void Main()`, not `int main()`
- Keep the main loop as `while (System::Update()) { ... }`; the window stays open while it returns `true`
- Exit via window close, Esc, `System::Exit()` (takes effect on the next `System::Update()`), or `return;` (immediate)

### Main loop discipline

- Split work into three parts:
  - Before the loop: setup (window/scene config, load textures/fonts)
  - Inside the loop: input handling and drawing
  - After the loop: rare cleanup (e.g. save on exit)
- Load heavy resources (e.g. `Texture`, `Font`) once before the loop; never create/destroy them every frame inside the loop

### Simple output

- Use `Print << value;` for quick text/number output
- Call `ClearPrint()` at the top of the loop to show only the current frame

### Strings and literals

- Always prefix string literals with `U` (UTF-32), e.g. `U"Hello"`
- Prefix character literals with `U`, e.g. `U'A'`

### Preferred types

- Integers: use sized types such as `int32` and `uint64`; use `size_t` for sizes/indices; avoid `int` and `long`
- Floating point: prefer `double`; use `float` only where APIs require it
- Boolean: `bool`
- Character: `char32`
- String: `String` (also `StringView`, `FilePath`, `FilePathView` aliases)
- Containers: `Array<Type>` (dynamic), `std::array<Type, N>` (fixed), `Grid<Type>` (2D), `Optional<Type>`, `HashSet<Type>`, `HashTable<Key, Value>`
