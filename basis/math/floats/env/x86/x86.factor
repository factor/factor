USING: accessors alien.c-types arrays assocs biassocs
classes.struct combinators cpu.x86.features kernel literals
math math.bitwise math.floats.env math.floats.env.private
system vocabs ;
IN: math.floats.env.x86

STRUCT: sse-env
    { mxcsr uint } ;

STRUCT: x87-env
    { status ushort }
    { control ushort } ;

HOOK: get-sse-env cpu ( sse-env -- )
HOOK: set-sse-env cpu ( sse-env -- )

HOOK: get-x87-env cpu ( x87-env -- )
HOOK: set-x87-env cpu ( x87-env -- )

: <sse-env> ( -- sse-env )
    sse-env (struct) [ get-sse-env ] keep ;

M: sse-env (set-fp-env-register)
    set-sse-env ;

: <x87-env> ( -- x87-env )
    x87-env (struct) [ get-x87-env ] keep ;

M: x87-env (set-fp-env-register)
    set-x87-env ;

M: x86 (fp-env-registers)
    sse2? [ <sse-env> <x87-env> 2array ] [ <x87-env> 1array ] if ;

CONSTANT: sse-exception-flag-bits 0x3f
CONSTANT: sse-exception-flag>bit
    H{
        { +fp-invalid-operation+ 0x01 }
        { +fp-overflow+          0x08 }
        { +fp-underflow+         0x10 }
        { +fp-zero-divide+       0x04 }
        { +fp-inexact+           0x20 }
    }

CONSTANT: sse-fp-traps-bits 0x1f80
CONSTANT: sse-fp-traps>bit
    H{
        { +fp-invalid-operation+ 0x0080 }
        { +fp-overflow+          0x0400 }
        { +fp-underflow+         0x0800 }
        { +fp-zero-divide+       0x0200 }
        { +fp-inexact+           0x1000 }
    }

CONSTANT: sse-rounding-mode-bits 0x6000
CONSTANT: sse-rounding-mode>bit
    $[ H{
        { +round-nearest+ 0x0000 }
        { +round-down+    0x2000 }
        { +round-up+      0x4000 }
        { +round-zero+    0x6000 }
    } >biassoc ]

CONSTANT: sse-denormal-mode-bits 0x8040

M: sse-env (get-exception-flags)
    mxcsr>> sse-exception-flag>bit mask> ; inline
M: sse-env (set-exception-flags)
    [ sse-exception-flag>bit >mask sse-exception-flag-bits remask ] curry change-mxcsr ; inline

M: sse-env (get-fp-traps)
    mxcsr>> bitnot sse-fp-traps>bit mask> ; inline
M: sse-env (set-fp-traps)
    [ sse-fp-traps>bit >mask bitnot sse-fp-traps-bits remask ] curry change-mxcsr ; inline

M: sse-env (get-rounding-mode)
    mxcsr>> sse-rounding-mode-bits mask sse-rounding-mode>bit value-at ; inline
M: sse-env (set-rounding-mode)
    [ sse-rounding-mode>bit at sse-rounding-mode-bits remask ] curry change-mxcsr ; inline

M: sse-env (get-denormal-mode)
    mxcsr>> sse-denormal-mode-bits mask zero? +denormal-keep+ +denormal-flush+ ? ; inline
M: sse-env (set-denormal-mode)
    [
        {
            { +denormal-keep+  [ sse-denormal-mode-bits unmask ] }
            { +denormal-flush+ [ sse-denormal-mode-bits bitor  ] }
        } case
    ] curry change-mxcsr ; inline

SINGLETON: +fp-x87-stack-fault+

CONSTANT: x87-exception-bits 0x7f
CONSTANT: x87-exception>bit
    H{
        { +fp-invalid-operation+ 0x01 }
        { +fp-overflow+          0x08 }
        { +fp-underflow+         0x10 }
        { +fp-zero-divide+       0x04 }
        { +fp-inexact+           0x20 }
        { +fp-x87-stack-fault+   0x40 }
    }

CONSTANT: x87-rounding-mode-bits 0x0c00
CONSTANT: x87-rounding-mode>bit
    $[ H{
        { +round-nearest+ 0x0000 }
        { +round-down+    0x0400 }
        { +round-up+      0x0800 }
        { +round-zero+    0x0c00 }
    } >biassoc ]

M: x87-env (get-exception-flags)
    status>> x87-exception>bit mask> ; inline
M: x87-env (set-exception-flags)
    drop ;

M: x87-env (get-fp-traps)
    control>> bitnot x87-exception>bit mask> ; inline
M: x87-env (set-fp-traps)
    [ x87-exception>bit >mask bitnot x87-exception-bits remask ] curry change-control ; inline

M: x87-env (get-rounding-mode)
    control>> x87-rounding-mode-bits mask x87-rounding-mode>bit value-at ; inline
M: x87-env (set-rounding-mode)
    [ x87-rounding-mode>bit at x87-rounding-mode-bits remask ] curry change-control ; inline

M: x87-env (get-denormal-mode)
    drop +denormal-keep+ ; inline
M: x87-env (set-denormal-mode)
    drop ;

cpu {
    { x86.32 [ "math.floats.env.x86.32" ] }
    { x86.64 [ "math.floats.env.x86.64" ] }
} case require
