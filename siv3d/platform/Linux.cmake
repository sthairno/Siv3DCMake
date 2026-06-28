find_package(Siv3D REQUIRED)
get_target_property(SIV3D_SYSTEM_INCLUDE_DIRS Siv3D::Siv3D INTERFACE_INCLUDE_DIRECTORIES)

set(SIV3D_ROOT "${CMAKE_CURRENT_LIST_DIR}/../sdk")
set(SIV3D_INCLUDE_DIR "${SIV3D_ROOT}/include")
foreach(include_dir IN LISTS SIV3D_SYSTEM_INCLUDE_DIRS)
    if(EXISTS "${include_dir}/Siv3D.hpp")
        set(SIV3D_SYSTEM_INCLUDE_DIR "${include_dir}")
        break()
    endif()
endforeach()

if(NOT SIV3D_SYSTEM_INCLUDE_DIR)
    message(FATAL_ERROR
        "Failed to find Siv3D include directory: ${SIV3D_SYSTEM_INCLUDE_DIRS}")
endif()

# Create symlink from SIV3D_SYSTEM_INCLUDE_DIR to SIV3D_INCLUDE_DIR
file(REMOVE_RECURSE "${SIV3D_INCLUDE_DIR}")
file(CREATE_LINK
    "${SIV3D_SYSTEM_INCLUDE_DIR}"
    "${SIV3D_INCLUDE_DIR}"
    SYMBOLIC
)

function(_siv3d_platform_add_resources target resource_paths resource_types)
    list(LENGTH resource_paths path_count)
    if(path_count EQUAL 0)
        return()
    endif()

    math(EXPR last_index "${path_count} - 1")
    foreach(i RANGE ${last_index})
        list(GET resource_paths ${i} resource_abspath)
        list(GET resource_types ${i} resource_type)
        file(RELATIVE_PATH resource_relpath "${SIV3D_RESOURCES_PATH}" "${resource_abspath}")

        if(resource_type STREQUAL "EMBED")
            set(destination_relpath "resources/${resource_relpath}")
        elseif(resource_type STREQUAL "COPY")
            set(destination_relpath "${resource_relpath}")
        endif()

        get_filename_component(resource_directory_relpath "${destination_relpath}" DIRECTORY)
        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory
                "$<TARGET_FILE_DIR:${target}>/${resource_directory_relpath}"
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${resource_abspath}"
                "$<TARGET_FILE_DIR:${target}>/${destination_relpath}"
            VERBATIM
        )
    endforeach()
endfunction()

message(STATUS "Configured Siv3D SDK [Linux]")
message(STATUS "  Include: ${SIV3D_SYSTEM_INCLUDE_DIR} -> ${SIV3D_INCLUDE_DIR}")
