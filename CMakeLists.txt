cmake_minimum_required(VERSION 3.16)
project(Siv3DApp LANGUAGES CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(siv3d/Siv3D.cmake)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(WIN32)
    # Siv3D Windows SDK libs are built with static CRT (/MT, /MTd)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    add_executable(Siv3DApp WIN32 src/Main.cpp)
else()
    add_executable(Siv3DApp src/Main.cpp)
endif()
target_link_libraries(Siv3DApp PRIVATE Siv3D::Siv3D)

# Setup bundle properties
set_target_properties(Siv3DApp PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${PROJECT_SOURCE_DIR}/App"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${PROJECT_SOURCE_DIR}/App"
    OUTPUT_NAME "Siv3DApp"
    DEBUG_POSTFIX "-debug"
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
