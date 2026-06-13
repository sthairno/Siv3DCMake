cmake_minimum_required(VERSION 3.16)
project(Siv3DApp LANGUAGES CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(siv3d/Siv3D.cmake)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# アプリケーションのソースファイルの定義 / Definition of the application source files
#
# .cpp ファイルをAPP_SOURCE_FILESに追加することでビルド対象になります。
# You can add .cpp files to APP_SOURCE_FILES to include them in the build.

set(APP_SOURCE_FILES
    src/Main.cpp
)

# 実行ファイルの作成と Siv3D ライブラリのリンク / Creation of the executable and linking of the Siv3D library

add_executable(Siv3DApp ${APP_SOURCE_FILES})
target_link_libraries(Siv3DApp
    PRIVATE Siv3D::Siv3D
)

# 実行ファイル・アプリバンドルの各種プロパティの設定 / Properties of the executable and app bundle

set_target_properties(Siv3DApp PROPERTIES
    # 実行ファイルの出力先ディレクトリ / Output directory for the executable
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/App"
    # 実行ファイルの名前 / Name of the executable
    OUTPUT_NAME "Siv3DApp"
    # デバッグビルド時に"-debug"を末尾に追加 / Append "-debug" to the output name for debug builds
    DEBUG_POSTFIX "-debug"
    # macOSのビルド設定 / Build settings for macOS
    MACOSX_BUNDLE ON
    MACOSX_BUNDLE_INFO_PLIST "${PROJECT_SOURCE_DIR}/src/macOS/Info.plist"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.example.siv3d-app"
)

# アプリに埋め込むリソースを定義 / Define resources to embed in the application
#
# 使い方 / Usage:
#
#   siv3d_resources(
#       target
#       platform resource-type path
#       ...
#   )
# 
# パラメータ / Parameters:
#
#   platform
#    - ALL: 全てのプラットフォーム / All platforms
#    - MACOS:  macOS のみ / macOS only
#    - WINDOWS: Windows のみ / Windows only
#    - LINUX: Linux のみ / Linux only
#
#   resource-type
#    - EMBED: リソースを実行ファイルに埋め込む / Embed the resource into the executable
#    - COPY: リソースを実行ファイルと同じディレクトリにコピーする / Copy the resource next to the executable file
#
#    ! MacOSビルドのみ、resource-typeにかかわらず常にEMBEDの動作になります
#    ! On MacOS build, the behavior is always EMBED regardless of the resource-type
#
#   path: ディレクトリまたはファイルのパス / Path to the directory or file

siv3d_resources(
    Siv3DApp
    ALL     EMBED "engine/font"
    MACOS   EMBED "engine/lib/soundtouch"
    WINDOWS EMBED "engine/shader/d3d11"
    MACOS   EMBED "engine/shader/msl"
    LINUX   EMBED "engine/shader/essl"
    ALL     EMBED "engine/shader/glsl"
    ALL     EMBED "engine/soundfont"
    ALL     EMBED "engine/texture"
    WINDOWS COPY  "dll"
    MACOS   EMBED "icon.icns"
    WINDOWS EMBED "icon.ico"
    ALL     COPY  "example"
)
