set(SIV3D_RESOURCES_PATH "${CMAKE_CURRENT_SOURCE_DIR}/resources")
set(SIV3D_VALID_PLATFORMS ALL MACOS WINDOWS LINUX)
set(SIV3D_VALID_RESOURCE_TYPES EMBED COPY)
set_property(DIRECTORY APPEND PROPERTY
    ADDITIONAL_CLEAN_FILES "${CMAKE_CURRENT_SOURCE_DIR}/App"
)

if(APPLE)
    set(SIV3D_PLATFORM MACOS)
    include("${CMAKE_CURRENT_SOURCE_DIR}/siv3d/platform/MacOS.cmake")
elseif(WIN32)
    set(SIV3D_PLATFORM WINDOWS)
    include("${CMAKE_CURRENT_SOURCE_DIR}/siv3d/platform/Windows.cmake")
elseif(UNIX)
    set(SIV3D_PLATFORM LINUX)
    include("${CMAKE_CURRENT_SOURCE_DIR}/siv3d/platform/Linux.cmake")
else()
    message(FATAL_ERROR "Unsupported platform: ${CMAKE_HOST_SYSTEM_NAME}")
endif()

function(siv3d_resources target)
    if(NOT TARGET "${target}")
        message(FATAL_ERROR "siv3d_resources: target not found: ${target}")
    endif()

    list(LENGTH ARGN arg_count)
    if(arg_count LESS 3)
        message(FATAL_ERROR
            "siv3d_resources: at least one resource entry (platform resource-type path) is required")
    endif()

    math(EXPR remainder "${arg_count} % 3")
    if(NOT remainder EQUAL 0)
        message(FATAL_ERROR
            "siv3d_resources: arguments must be groups of 3 (platform resource-type path)")
    endif()

    math(EXPR last_index "${arg_count} - 3")
    foreach(platform_index RANGE 0 ${last_index} 3)
        math(EXPR resource_type_index "${platform_index} + 1")
        math(EXPR path_index "${platform_index} + 2")

        list(GET ARGN ${platform_index} arg_platform)
        list(GET ARGN ${resource_type_index} arg_resource_type)
        list(GET ARGN ${path_index} arg_path)

        if(NOT arg_platform IN_LIST SIV3D_VALID_PLATFORMS)
            message(FATAL_ERROR
                "siv3d_resources: unknown platform '${arg_platform}' in entry "
                "'${arg_platform} ${arg_resource_type} ${arg_path}'. "
                "Valid platforms: ALL, MACOS, WINDOWS, LINUX")
        endif()

        if(NOT arg_resource_type IN_LIST SIV3D_VALID_RESOURCE_TYPES)
            message(FATAL_ERROR
                "siv3d_resources: unknown resource-type '${arg_resource_type}' in entry "
                "'${arg_platform} ${arg_resource_type} ${arg_path}'. "
                "Valid resource-types: EMBED, COPY")
        endif()

        if(NOT arg_platform STREQUAL "ALL" AND NOT arg_platform STREQUAL "${SIV3D_PLATFORM}")
            continue()
        endif()

        set(arg_path_absolute "${SIV3D_RESOURCES_PATH}/${arg_path}")
        if(IS_DIRECTORY "${arg_path_absolute}")
            file(GLOB_RECURSE extracted_paths CONFIGURE_DEPENDS "${arg_path_absolute}/*")
        elseif(EXISTS "${arg_path_absolute}")
            set(extracted_paths "${arg_path_absolute}")
        else()
            message(FATAL_ERROR "Siv3D resource path not found: ${arg_path_absolute}")
        endif()

        foreach(extracted_path IN LISTS extracted_paths)
            list(APPEND resource_paths "${extracted_path}")
            list(APPEND resource_types "${arg_resource_type}")
        endforeach()
    endforeach()

    if(NOT resource_paths OR NOT COMMAND _siv3d_platform_add_resources)
        return()
    endif()

    _siv3d_platform_add_resources("${target}" "${resource_paths}" "${resource_types}")
endfunction()
