USING: accessors alien.c-types alien.syntax arrays assocs
biassocs classes.struct combinators cpu.x86.features kernel
literals math math.bitwise math.floats.env
math.floats.env.private system ;
IN: math.floats.env.x86

STRUCT: sse-env
    { mxcsr uint } ;

STRUCT: x87-env
    { status ushort }
    { control ushort } ;

! defined in the vm, cpu-x86*.S
FUNCTION: void get_sse_env ( sse-env* env ) ;
FUNCTION: void set_sse_env ( sse-env* env ) ;

FUNCTION: void get_x87_env ( x87-env* env ) ;
FUNCTION: void set_x87_env ( x87-env* env ) ;

: <sse-env> ( -- sse-env )
    sse-env (struct) [ get_sse_env ] keep ;

M: sse-env (set-fp-env-register)
    set_sse_env ;

: <x87-env> ( -- x87-env )
    x87-env (struct) [ get_x87_env ] keep ;

M: x87-env (set-fp-env-register)
    set_x87_env ;

M: x86 (fp-env-registers)
    sse2? [ <sse-env> <x87-env> 2array ] [ <x87-env> 1array ] if ;

CONSTANT: sse-exception-flag-bits HEX: 3f
CONSTANT: sse-exception-flag>bit
    H{
        { +fp-invalid-operation+ HEX: 01 }
        { +fp-overflow+          HEX: 08 }
        { +fp-underflow+         HEX: 10 }
        { +fp-zero-divide+       HEX: 04 }
        { +fp-inexact+           HEX: 20 }
    }

CONSTANT: sse-fp-traps-bits HEX: 1f80
CONSTANT: sse-fp-traps>bit
    H{
        { +fp-invalid-operation+ HEX: 0080 }
        { +fp-overflow+          HEX: 0400 }
        { +fp-underflow+         HEX: 0800 }
        { +fp-zero-divide+       HEX: 0200 }
        { +fp-inexact+           HEX: 1000 }
    }

CONSTANT: sse-rounding-mode-bits HEX: 6000
CONSTANT: sse-rounding-mode>bit
    $[ H{
        { +round-nearest+ HEX: 0000 }
        { +round-down+    HEX: 2000 }
        { +round-up+      HEX: 4000 }
        { +round-zero+    HEX: 6000 }
    } >biassoc ]

CONSTANT: sse-denormal-mode-bits HEX: 8040

M: sse-env (get-exception-flags) ( register -- exceptions )
    mxcsr>> sse-exception-flag>bit mask> ; inline
M: sse-env (set-exception-flags) ( register exceptions -- register' )
    [ sse-exception-flag>bit >mask sse-exception-flag-bits remask ] curry change-mxcsr ; inline

M: sse-env (get-fp-traps) ( register -- exceptions )
    mxcsr>> bitnot sse-fp-traps>bit mask> ; inline
M: sse-env (set-fp-traps) ( register exceptions -- register' )
    [ sse-fp-traps>bit >mask bitnot sse-fp-traps-bits remask ] curry change-mxcsr ; inline

M: sse-env (get-rounding-mode) ( register -- mode )
    mxcsr>> sse-rounding-mode-bits mask sse-rounding-mode>bit value-at ; inline
M: sse-env (set-rounding-mode) ( register mode -- register' )
    [ sse-rounding-mode>bit at sse-rounding-mode-bits remask ] curry change-mxcsr ; inline

M: sse-env (get-denormal-mode) ( register -- mode )
    mxcsr>> sse-denormal-mode-bits mask zero? +denormal-keep+ +denormal-flush+ ? ; inline
M: sse-env (set-denormal-mode) ( register mode -- register' )
    [
        {
            { +denormal-keep+  [ sse-denormal-mode-bits unmask ] }
            { +denormal-flush+ [ sse-denormal-mode-bits bitor  ] }
        } case
    ] curry change-mxcsr ; inline

CONSTANT: x87-exception-bits HEX: 3f
CONSTANT: x87-exception>bit
    H{
        { +fp-invalid-operation+ HEX: 01 }
        { +fp-overflow+          HEX: 08 }
        { +fp-underflow+         HEX: 10 }
        { +fp-zero-divide+       HEX: 04 }
        { +fp-inexact+           HEX: 20 }
    }

CONSTANT: x87-rounding-mode-bits HEX: 0c00
CONSTANT: x87-rounding-mode>bit
    $[ H{
        { +round-nearest+ HEX: 0000 }
        { +round-down+    HEX: 0400 }
        { +round-up+      HEX: 0800 }
        { +round-zero+    HEX: 0c00 }
    } >biassoc ]

M: x87-env (get-exception-flags) ( register -- exceptions )
    status>> x87-exception>bit mask> ; inline
M: x87-env (set-exception-flags) ( register exceptions -- register' )
    drop ;

M: x87-env (get-fp-traps) ( register -- exceptions )
    control>> bitnot x87-exception>bit mask> ; inline
M: x87-env (set-fp-traps) ( register exceptions -- register' )
    [ x87-exception>bit >mask bitnot x87-exception-bits remask ] curry change-control ; inline

M: x87-env (get-rounding-mode) ( register -- mode )
    control>> x87-rounding-mode-bits mask x87-rounding-mode>bit value-at ; inline
M: x87-env (set-rounding-mode) ( register mode -- register' )
    [ x87-rounding-mode>bit at x87-rounding-mode-bits remask ] curry change-control ; inline

M: x87-env (get-denormal-mode) ( register -- mode )
    drop +denormal-keep+ ; inline
M: x87-env (set-denormal-mode) ( register mode -- register' )
    drop ;

