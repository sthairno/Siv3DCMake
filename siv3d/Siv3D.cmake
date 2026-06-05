if(APPLE)
    set(SIV3D_PLATFORM MACOS)
    include("${CMAKE_CURRENT_SOURCE_DIR}/siv3d/platform/MacOS.cmake")
elseif(WIN32)
    set(SIV3D_PLATFORM WINDOWS)
    include("${CMAKE_CURRENT_SOURCE_DIR}/siv3d/platform/Windows.cmake")
elseif(UNIX)
    set(SIV3D_PLATFORM LINUX)
else()
    message(FATAL_ERROR "Unsupported platform: ${CMAKE_HOST_SYSTEM_NAME}")
endif()

function(siv3d_add_resources target directory)
    cmake_parse_arguments(SIV3D_RESOURCES
        ""
        ""
        "EXCLUDE_PATTERNS;PLATFORMS"
        ${ARGN}
    )

    if(NOT SIV3D_RESOURCES_PLATFORMS)
        set(SIV3D_RESOURCES_PLATFORMS MACOS WINDOWS LINUX)
    endif()

    if(NOT SIV3D_PLATFORM IN_LIST SIV3D_RESOURCES_PLATFORMS OR
       NOT COMMAND _siv3d_platform_add_resource)
        return()
    endif()

    set(resource_root "${CMAKE_CURRENT_SOURCE_DIR}/resources")
    if(IS_ABSOLUTE "${directory}")
        set(resource_dir "${directory}")
    else()
        set(resource_dir "${resource_root}/${directory}")
    endif()

    file(GLOB_RECURSE resource_files CONFIGURE_DEPENDS
        "${resource_dir}/*"
    )

    foreach(resource IN LISTS resource_files)
        if(IS_DIRECTORY "${resource}")
            continue()
        endif()

        file(RELATIVE_PATH rel_path "${resource_root}" "${resource}")
        set(excluded FALSE)
        foreach(exclude_path IN LISTS SIV3D_RESOURCES_EXCLUDE_PATTERNS)
            string(FIND "${rel_path}/" "${exclude_path}/" exclude_index)
            if(exclude_index EQUAL 0)
                set(excluded TRUE)
            endif()
        endforeach()
        if(excluded)
            continue()
        endif()

        _siv3d_platform_add_resource("${target}" "${resource}" "${rel_path}")
    endforeach()
endfunction()
