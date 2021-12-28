
cmake_minimum_required(VERSION 3.4.1)
include_directories(../include)
add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/cmakeLibs/${ANDROID_ABI}/libopencv_java4.so)
set(CPP_DIR "../ios/Classes")
set(SOURCES
    ${CPP_DIR}/opencvTest.cpp
)
add_library(opencv SHARED ${SOURCES})
target_link_libraries(opencv lib_opencv)
