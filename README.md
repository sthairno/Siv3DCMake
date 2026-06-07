# Siv3DCMake

[Siv3D](https://siv3d.github.io/) v0.6.16 を CMake でビルドするサンプルプロジェクトです。

## 前提

- CMake 3.23 以上
- 推奨 VS Code 拡張（[`.vscode/extensions.json`](.vscode/extensions.json) 参照）
  - [CMake Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools)
  - [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)
  - [clangd](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd)

### プラットフォーム別

| OS | 追加要件 |
|----|----------|
| Windows | Visual Studio Build Tools、clang（`windows-debug` preset 参照） |
| macOS | Xcode Command Line Tools |
| Linux | GCC/Clang、開発用ライブラリ |

## ビルド設定の SSOT

[`CMakePresets.json`](CMakePresets.json) が唯一の真実の源です。VS Code・CLI・CI はすべてこの preset を使います。

### Preset 一覧

| Configure Preset | Build Preset | Workflow Preset |
|------------------|--------------|-----------------|
| `linux-debug` | `build-linux-debug` | `workflow-linux-debug` |
| `linux-release` | `build-linux-release` | `workflow-linux-release` |
| `macos-debug` | `build-macos-debug` | `workflow-macos-debug` |
| `macos-release` | `build-macos-release` | `workflow-macos-release` |
| `windows-debug` | `build-windows-debug` | `workflow-windows-debug` |
| `windows-release` | `build-windows-release` | `workflow-windows-release` |

## コマンドライン

```powershell
# Windows (Debug) — configure + build を分ける
cmake --preset windows-debug
cmake --build --preset build-windows-debug

# または workflow で一括
cmake --workflow --preset workflow-windows-debug
```

```bash
# Linux / macOS も同様（preset 名を OS に合わせて変更）
cmake --preset linux-debug
cmake --build --preset build-linux-debug
```

実行ファイルは configure preset の `binaryDir` 配下に出力されます（Debug 例: `build/Debug/Siv3DApp` または `build/Debug/Siv3DApp.exe`）。

## VS Code での開発

1. リポジトリを開く
2. **CMake: Select Configure Preset** で OS に対応する debug preset を選択
3. **CMake: Configure** → **CMake: Build**
4. デバッグ
   - **F5** / Run and Debug パネル → `Debug Siv3DApp`（[`launch.json`](.vscode/launch.json)）
   - CMake サイドバーの **Debug** ボタン（[`settings.json`](.vscode/settings.json) の `cmake.debugConfig`）

初回 configure 後、`compile_commands.json` が `build/` にコピーされ、clangd が IntelliSense に利用します。

### トラブルシュート

- **launch / デバッグが失敗する** — 先に CMake configure が成功しているか確認してください。`cmake.launchTargetPath` は configure 後にのみ解決されます。
- **Windows でビルドできない** — `.vscode/settings.json` の `cmake.useVsDeveloperEnvironment: always` により CMake Tools は VS 開発者環境を使用します。CLI からビルドする場合は [`.agent/rules/windows-shell.mdc`](.agent/rules/windows-shell.mdc) の DevShell 手順を参照してください。
- **IntelliSense が更新されない** — configure を再実行し、`build/compile_commands.json` が更新されているか確認してください。

## プロジェクト構成

```
CMakeLists.txt          # ルート CMake
CMakePresets.json       # ビルド preset（SSOT）
siv3d/                  # Siv3D SDK 取得・リンク設定
src/Main.cpp            # エントリポイント
resources/              # Siv3D リソース（exe / bundle に埋め込み）
```
