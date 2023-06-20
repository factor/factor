! Copyright (C) 2023 Sebastian Strobl.
! See https://factorcode.org/license.txt for BSD license.
USING: glfw.ffi alien alien.syntax alien.libraries alien.c-types system combinators ;
QUALIFIED-WITH: vulkan vk

IN: glfw.vulkan-interop

<<
"glfw" {
    { [ os windows? ] [ "glfw3.dll" ] }
    { [ os macosx? ] [ "glfw3.dylib" ] }
    { [ os unix? ] [ "libglfw3.so" ] }
} cond cdecl add-library
>>

LIBRARY: glfw

FUNCTION: GLFWvkproc glfwGetInstanceProcAddress ( vk:Instance instance, char* procname )
FUNCTION: int glfwGetPhysicalDevicePresentationSupport ( vk:Instance instance, vk:PhysicalDevice device, uint queuefamily )
FUNCTION: vk:Result glfwCreateWindowSurface ( vk:Instance instance, GLFWwindow* window, vk:AllocationCallbacks* allocator, vk:SurfaceKHR surface )