! Copyright (C) 2024 Dmitry Matveyev.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax ;
IN: raylib.live-coding.glfw

! Raylib statically compiles GLFW into the library and exposes
! all functions from there. We *MUST* use Raylib's GLFW to
! manipulate OpenGL context, namely to disable it when listener
! needs to render its window. Using external GLFW will not
! affect Raylib's window, this is why here I duplicate a
! minimal subset of bindings I need instead of using glfw.fii
! vocabulary, which links external GLFW dynamically.

LIBRARY: glfw

TYPEDEF: void* GLFWwindow
FUNCTION-ALIAS: make-context-current void glfwMakeContextCurrent ( GLFWwindow* window )
