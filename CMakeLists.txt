cmake_minimum_required(VERSION 3.16)
project(Siv3DApp LANGUAGES CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(siv3d/Siv3D.cmake)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(Siv3DApp src/Main.cpp)
target_link_libraries(Siv3DApp PRIVATE Siv3D::Siv3D)

# Setup bundle properties
if (APPLE)
set_target_properties(Siv3DApp PROPERTIES
    MACOSX_BUNDLE ON
    MACOSX_BUNDLE_INFO_PLIST "${PROJECT_SOURCE_DIR}/src/macOS/Info.plist"
    MACOSX_BUNDLE_BUNDLE_NAME "${PROJECT_NAME}"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.example.siv3d-app"
)
endif()

# Add engine resources to the target
siv3d_add_resources(Siv3DApp "dll" PLATFORMS WINDOWS)
siv3d_add_resources(Siv3DApp "engine" EXCLUDE_PATTERNS "engine/shader" "engine/lib")
siv3d_add_resources(Siv3DApp "engine/shader/d3d11" PLATFORMS WINDOWS)
siv3d_add_resources(Siv3DApp "engine/shader/glsl")
siv3d_add_resources(Siv3DApp "engine/shader/msl" PLATFORMS MACOS)
siv3d_add_resources(Siv3DApp "engine/lib" PLATFORMS MACOS)
siv3d_add_resources(Siv3DApp "icon.icns" PLATFORMS MACOS)
siv3d_add_resources(Siv3DApp "example")