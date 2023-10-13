! Copyright (C) 2023 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: glfw.ffi threads ;
IN: glfw

: glfw-yield ( -- )
    glfwGetCurrentContext
    f glfwMakeContextCurrent
    yield
    glfwMakeContextCurrent ;
