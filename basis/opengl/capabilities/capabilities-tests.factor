! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: opengl.capabilities tools.test ;
IN: opengl.capabilities.tests

CONSTANT: test-extensions
    {
        "GL_ARB_vent_core_frogblast"
        "GL_EXT_resonance_cascade"
        "GL_EXT_slipgate"
    }

{ t }
[ "GL_ARB_vent_core_frogblast" test-extensions (has-extension?) ] unit-test

{ f }
[ "GL_ARB_wallhack" test-extensions (has-extension?) ] unit-test

{ t } [
    { "GL_EXT_dimensional_portal" "GL_EXT_slipgate" }
    test-extensions (has-extension?)
] unit-test
