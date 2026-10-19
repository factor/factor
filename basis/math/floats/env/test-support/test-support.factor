USING: kernel locals math math.floats.env tools.test tools.test.private ;
IN: math.floats.env.test-support

<PRIVATE

:: (rounding-mode-unit-test) ( output input mode -- error/f failed? tested? )
    floating-point-supported? [
        mode rounding-mode-supported? [
            output input (unit-test)
        ] [ "rounding mode unsupported" f f ] if
    ] [ "floating point unsupported" f f ] if ;

PRIVATE>

DEFINE-TEST-WORD: rounding-mode-unit-test
