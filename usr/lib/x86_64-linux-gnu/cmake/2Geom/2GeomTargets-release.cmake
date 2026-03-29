#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "2Geom::2geom" for configuration "Release"
set_property(TARGET 2Geom::2geom APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(2Geom::2geom PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/x86_64-linux-gnu/lib2geom.so.1.3.0"
  IMPORTED_SONAME_RELEASE "lib2geom.so.1.3.0"
  )

list(APPEND _IMPORT_CHECK_TARGETS 2Geom::2geom )
list(APPEND _IMPORT_CHECK_FILES_FOR_2Geom::2geom "${_IMPORT_PREFIX}/lib/x86_64-linux-gnu/lib2geom.so.1.3.0" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
