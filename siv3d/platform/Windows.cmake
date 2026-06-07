# Config

set(SIV3D_VERSION "0.6.16")
set(SIV3D_ROOT "${CMAKE_CURRENT_LIST_DIR}/../sdk/${SIV3D_VERSION}")
set(SIV3D_INCLUDE_DIR "${SIV3D_ROOT}/include")
set(SIV3D_LIB_DIR "${SIV3D_ROOT}/lib/Windows")
set(SIV3D_GENERATED_RC_PATH "${CMAKE_BINARY_DIR}/Resource.rc")
set(SIV3D_DOWNLOAD_DIR "${CMAKE_CURRENT_BINARY_DIR}/siv3d_download")
set(SIV3D_EXTRACTED FALSE)
if(EXISTS "${SIV3D_ROOT}" AND IS_DIRECTORY "${SIV3D_ROOT}")
    set(SIV3D_EXTRACTED TRUE)
endif()

set(SIV3D_WINDOWS_ZIP_URL "https://siv3d.jp/downloads/Siv3D/manual/0.6.16/OpenSiv3D_SDK_${SIV3D_VERSION}.zip")

enable_language(RC)

# Download and extract Siv3D SDK

if(NOT SIV3D_EXTRACTED)
    set(SIV3D_WINDOWS_TEMP_ZIP_PATH "${SIV3D_DOWNLOAD_DIR}/windows_${SIV3D_VERSION}.zip")
    set(SIV3D_WINDOWS_TEMP_INNER_DIR "${SIV3D_DOWNLOAD_DIR}/OpenSiv3D_SDK_${SIV3D_VERSION}")

    # 一時ディレクトリを作成
    file(MAKE_DIRECTORY "${SIV3D_DOWNLOAD_DIR}")

    # ZIPファイルのダウンロード
    if(NOT EXISTS "${SIV3D_WINDOWS_TEMP_ZIP_PATH}")
        message(STATUS "Downloading Siv3D SDK from: ${SIV3D_WINDOWS_ZIP_URL}")
        file(DOWNLOAD
            "${SIV3D_WINDOWS_ZIP_URL}"
            "${SIV3D_WINDOWS_TEMP_ZIP_PATH}"
            SHOW_PROGRESS
            STATUS download_status
        )
        list(GET download_status 0 status_code)
        if(NOT status_code EQUAL 0)
            list(GET download_status 1 error_message)
            message(FATAL_ERROR"Failed to download ZIP file: ${error_message}")
        endif()
    endif()

    # ZIPファイルの展開
    message(STATUS "Extracting Siv3D SDK")

    if(NOT EXISTS "${SIV3D_WINDOWS_TEMP_INNER_DIR}")
        execute_process(
            COMMAND powershell -NoProfile -ExecutionPolicy Bypass -Command
                "Expand-Archive -LiteralPath '${SIV3D_WINDOWS_TEMP_ZIP_PATH}' -DestinationPath '${SIV3D_DOWNLOAD_DIR}' -Force"
            RESULT_VARIABLE extract_result
            OUTPUT_QUIET
            ERROR_VARIABLE extract_error
        )
        if(NOT extract_result EQUAL 0)
            message(FATAL_ERROR "Failed to extract ZIP file: ${extract_result}\n${extract_error}")
        endif()
    endif()

    file(COPY "${SIV3D_WINDOWS_TEMP_INNER_DIR}/lib/Windows/" DESTINATION "${SIV3D_LIB_DIR}")
    file(COPY "${SIV3D_WINDOWS_TEMP_INNER_DIR}/include/" DESTINATION "${SIV3D_INCLUDE_DIR}")
endif()

# Setup Siv3D::Siv3D target

add_library(Siv3DWindows INTERFACE)
add_library(Siv3D::Siv3D ALIAS Siv3DWindows)

# lld-link misparses forward-slash library paths (e.g. /curl/... as flags).
# Pass -libpath per directory and link by filename only.
set(SIV3D_WINDOWS_LINK_DIRS
    "${SIV3D_LIB_DIR}"
    "${SIV3D_LIB_DIR}/boost"
    "${SIV3D_LIB_DIR}/curl"
    "${SIV3D_LIB_DIR}/freetype"
    "${SIV3D_LIB_DIR}/glew"
    "${SIV3D_LIB_DIR}/harfbuzz"
    "${SIV3D_LIB_DIR}/libgif"
    "${SIV3D_LIB_DIR}/libjpeg-turbo"
    "${SIV3D_LIB_DIR}/libogg"
    "${SIV3D_LIB_DIR}/libpng"
    "${SIV3D_LIB_DIR}/libtiff"
    "${SIV3D_LIB_DIR}/libvorbis"
    "${SIV3D_LIB_DIR}/libwebp"
    "${SIV3D_LIB_DIR}/Oniguruma"
    "${SIV3D_LIB_DIR}/opencv"
    "${SIV3D_LIB_DIR}/opus"
    "${SIV3D_LIB_DIR}/zlib"
)
foreach(link_dir IN LISTS SIV3D_WINDOWS_LINK_DIRS)
    target_link_options(Siv3DWindows INTERFACE "LINKER:-libpath:${link_dir}")
endforeach()

target_link_libraries(Siv3DWindows INTERFACE
    optimized Siv3D.lib
    debug     Siv3D_d.lib
    optimized libboost_filesystem-vc143-mt-s-x64-1_83.lib
    debug     libboost_filesystem-vc143-mt-sgd-x64-1_83.lib
    optimized libcurl.lib
    debug     libcurl-d.lib
    optimized freetype.lib
    debug     freetyped.lib
    optimized glew32s.lib
    debug     glew32sd.lib
    optimized harfbuzz.lib
    debug     harfbuzz_d.lib
    optimized libgif.lib
    debug     libgif_d.lib
    optimized turbojpeg-static.lib
    debug     turbojpeg-static_d.lib
    optimized libogg.lib
    debug     libogg_d.lib
    optimized libpng16.lib
    debug     libpng16_d.lib
    optimized tiff.lib
    debug     tiffd.lib
    optimized libvorbis_static.lib
    debug     libvorbis_static_d.lib
    optimized libvorbisfile_static.lib
    debug     libvorbisfile_static_d.lib
    optimized libwebp.lib
    debug     libwebp_debug.lib
    optimized Oniguruma.lib
    debug     Oniguruma_d.lib
    optimized opencv_core451.lib
    debug     opencv_core451d.lib
    optimized opencv_imgcodecs451.lib
    debug     opencv_imgcodecs451d.lib
    optimized opencv_imgproc451.lib
    debug     opencv_imgproc451d.lib
    optimized opencv_objdetect451.lib
    debug     opencv_objdetect451d.lib
    optimized opencv_photo451.lib
    debug     opencv_photo451d.lib
    optimized opencv_videoio451.lib
    debug     opencv_videoio451d.lib
    optimized opus.lib
    debug     opus_d.lib
    optimized opusfile.lib
    debug     opusfile_d.lib
    optimized zlib.lib
    debug     zlibd.lib
)

target_include_directories(Siv3DWindows INTERFACE
    "${SIV3D_INCLUDE_DIR}"
    "${SIV3D_INCLUDE_DIR}/ThirdParty"
)

function(_siv3d_platform_add_resource target resource rel_path)
    set_property(GLOBAL APPEND PROPERTY SIV3D_RESOURCES_PATH "${resource}")
    set_property(GLOBAL APPEND PROPERTY SIV3D_RESOURCES_RELPATH "${rel_path}")
    set_property(GLOBAL PROPERTY SIV3D_RESOURCES_TARGET "${target}")
endfunction()

function(_siv3d_windows_finalize_rc)
    get_property(target GLOBAL PROPERTY SIV3D_RESOURCES_TARGET)
    if(NOT target)
        return()
    endif()

    get_property(paths GLOBAL PROPERTY SIV3D_RESOURCES_PATH)
    get_property(rel_paths GLOBAL PROPERTY SIV3D_RESOURCES_RELPATH)

    file(WRITE "${SIV3D_GENERATED_RC_PATH}" "# include <Siv3D/Windows/Resource.hpp>\n\n")

    list(LENGTH paths path_count)
    math(EXPR last_index "${path_count} - 1")
    foreach(i RANGE ${last_index})
        list(GET paths ${i} path)
        list(GET rel_paths ${i} rel_path)
        if(rel_path STREQUAL "icon.ico")
            file(APPEND "${SIV3D_GENERATED_RC_PATH}" "DefineResource(100, ICON, ${path})\n")
        else()
            file(APPEND "${SIV3D_GENERATED_RC_PATH}" "DefineResource(${rel_path}, FILE, ${path})\n")
        endif()
    endforeach()

    set_source_files_properties("${SIV3D_GENERATED_RC_PATH}" PROPERTIES
        GENERATED TRUE
        OBJECT_DEPENDS "${paths}"
    )
    target_sources(${target} PRIVATE "${SIV3D_GENERATED_RC_PATH}")
    target_compile_options(${target} PRIVATE
        "$<$<COMPILE_LANGUAGE:RC>:-I${SIV3D_INCLUDE_DIR}>"
    )
endfunction()
cmake_language(DEFER CALL _siv3d_windows_finalize_rc)

message(STATUS "Configured Siv3D SDK [Windows]: ${SIV3D_ROOT}")
message(STATUS "  Include: ${SIV3D_INCLUDE_DIR}")
message(STATUS "  Library: ${SIV3D_LIB_DIR}")
message(STATUS "  Resource: ${SIV3D_GENERATED_RC_PATH}")
