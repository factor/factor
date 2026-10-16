cmake_minimum_required(VERSION 3.22)
project(factor_android LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(native_app_glue STATIC
    ${ANDROID_NDK}/sources/android/native_app_glue/android_native_app_glue.c)
target_include_directories(native_app_glue PUBLIC
    ${ANDROID_NDK}/sources/android/native_app_glue)

add_library(factor-android SHARED
    factor_android.cpp
    factor_android_assets.cpp
    factor_android_jni.cpp
    factor_android_text.cpp)
target_compile_definitions(factor-android PRIVATE _FILE_OFFSET_BITS=64)
target_link_options(factor-android PRIVATE
    "-Wl,-z,max-page-size=16384"
    "-Wl,-z,common-page-size=16384")
target_link_libraries(factor-android PRIVATE
    "-Wl,--whole-archive" native_app_glue "-Wl,--no-whole-archive"
    android log jnigraphics EGL GLESv3 dl m)

if(FACTOR_VM_ROOT)
    add_library(factor_vm SHARED IMPORTED)
    set_target_properties(factor_vm PROPERTIES
        IMPORTED_LOCATION "${FACTOR_VM_ROOT}/${ANDROID_ABI}/libfactor.so"
        IMPORTED_NO_SONAME TRUE)
    target_link_libraries(factor-android PRIVATE factor_vm)
endif()
