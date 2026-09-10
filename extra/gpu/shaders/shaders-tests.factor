! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays gpu.shaders gpu.shaders.private io.pathnames
kernel tools.test ;
IN: gpu.shaders.tests

{ "ERROR: foo.factor:20: Bad command or filename
INFO: foo.factor:30: The operation completed successfully
NOT:A:LOG:LINE"  }
[ T{ shader { filename "foo.factor" } { line 19 } }
"ERROR: 0:1: Bad command or filename
INFO: 0:11: The operation completed successfully
NOT:A:LOG:LINE" replace-log-line-numbers ] unit-test

SYMBOL: a-test-symbol

{ "shaders" } [
    a-test-symbol word-directory file-name
] unit-test

CONSTANT: test-vertex-shader T{ shader { kind vertex-shader } }
CONSTANT: test-fragment-shader T{ shader { kind fragment-shader } }

{ t } [ \ test-vertex-shader ?shader test-vertex-shader eq? ] unit-test
{ f } [ a-test-symbol ?shader ] unit-test
{ f } [ 123 ?shader ] unit-test
{ f } [ T{ feedback-format } ?shader ] unit-test

GLSL-PROGRAM: test-program test-vertex-shader test-fragment-shader ;

{ t } [
    test-program shaders>>
    test-vertex-shader test-fragment-shader 2array =
] unit-test
