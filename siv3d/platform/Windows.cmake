# Config

set(SIV3D_VERSION "0.6.16")
set(SIV3D_ROOT "${CMAKE_CURRENT_LIST_DIR}/../sdk/${SIV3D_VERSION}")
set(SIV3D_INCLUDE_DIR "${SIV3D_ROOT}/include")
set(SIV3D_LIB_DIR "${SIV3D_ROOT}/lib/Windows")
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

function(_siv3d_windows_apply_embed_resources target)
    get_target_property(embed_paths ${target} SIV3D_EMBED_PATHS)
    if(NOT embed_paths)
        return()
    endif()

    get_target_property(embed_rel_paths ${target} SIV3D_EMBED_RELPATHS)
    set(rc_path "${CMAKE_BINARY_DIR}/${target}_Resource.rc")

    file(WRITE "${rc_path}" "")

    list(LENGTH embed_paths path_count)
    math(EXPR last_index "${path_count} - 1")
    foreach(i RANGE ${last_index})
        list(GET embed_paths ${i} path)
        list(GET embed_rel_paths ${i} rel_path)
        if(rel_path STREQUAL "icon.ico")
            file(APPEND "${rc_path}" "DefineResource(100, ICON, ${path})\n")
        else()
            file(APPEND "${rc_path}" "DefineResource(${rel_path}, FILE, ${path})\n")
        endif()
    endforeach()


endfunction()

function(_siv3d_platform_add_resources target resource_paths resource_types)
    list(LENGTH resource_paths path_count)
    if(path_count EQUAL 0)
        return()
    endif()

    set_target_properties(${target} PROPERTIES
        RESOURCE "${resource_paths}"
    )
    
    set(generated_rc_path "${CMAKE_BINARY_DIR}/${target}_resource.rc")
    set(generated_rc_content "# include <Siv3D/Windows/Resource.hpp>\n\n")

    math(EXPR last_index "${path_count} - 1")
    foreach(i RANGE ${last_index})
        list(GET resource_paths ${i} resource_abspath)
        list(GET resource_types ${i} resource_type)
        file(RELATIVE_PATH resource_relpath "${SIV3D_RESOURCES_PATH}" "${resource_abspath}")

        if(resource_type STREQUAL "EMBED")
            if(resource_relpath STREQUAL "icon.ico")
                set(generated_rc_content "${generated_rc_content}DefineResource(100, ICON, ${resource_abspath})\n")
            else()
                set(generated_rc_content "${generated_rc_content}DefineResource(${resource_relpath}, FILE, ${resource_abspath})\n")
            endif()
        elseif(resource_type STREQUAL "COPY")
            get_filename_component(resource_directory_relpath "${resource_relpath}" DIRECTORY)
            add_custom_command(TARGET ${target} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E make_directory
                    "$<TARGET_FILE_DIR:${target}>/${resource_directory_relpath}"
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    "${resource_abspath}"
                    "$<TARGET_FILE_DIR:${target}>/${resource_relpath}"
                VERBATIM
            )
        endif()
    endforeach()

    file(WRITE "${generated_rc_path}" "${generated_rc_content}")
    set_source_files_properties("${generated_rc_path}" PROPERTIES
        GENERATED TRUE
        OBJECT_DEPENDS "${embed_paths}"
    )
    target_sources(${target} PRIVATE "${generated_rc_path}")
    target_compile_options(${target} PRIVATE
        "$<$<COMPILE_LANGUAGE:RC>:-I${SIV3D_INCLUDE_DIR}>"
    )
endfunction()

message(STATUS "Configured Siv3D SDK [Windows]: ${SIV3D_ROOT}")
message(STATUS "  Include: ${SIV3D_INCLUDE_DIR}")
message(STATUS "  Library: ${SIV3D_LIB_DIR}")
