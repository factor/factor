! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: opengl.capabilities splitting tools.test ;
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

{ "4.6.0" "NVIDIA 555.42" }
[ "4.6.0 NVIDIA 555.42" split-gl-version ] unit-test

{ "3.2" "V@0502.0" }
[ "OpenGL ES 3.2 V@0502.0" normalize-gl-version-string " " split1 ] unit-test

{ "1.1" "Vendor" }
[ "OpenGL ES-CM 1.1 Vendor" normalize-gl-version-string " " split1 ] unit-test

{ "3.20" "Vendor" }
[ "OpenGL ES GLSL ES 3.20 Vendor" normalize-gl-version-string " " split1 ] unit-test
