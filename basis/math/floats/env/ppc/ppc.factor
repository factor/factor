USING: accessors alien.syntax arrays assocs biassocs
classes.struct combinators kernel literals math math.bitwise
math.floats.env math.floats.env.private system ;
IN: math.floats.env.ppc

STRUCT: ppc-fpu-env
    { padding uint }
    { fpcsr uint } ;

! defined in the vm, cpu-ppc*.S
FUNCTION: void get_ppc_fpu_env ( ppc-fpu-env* env ) ;
FUNCTION: void set_ppc_fpu_env ( ppc-fpu-env* env ) ;

: <ppc-fpu-env> ( -- ppc-fpu-env )
    ppc-fpu-env (struct)
    [ get_ppc_fpu_env ] keep ;

M: ppc-fpu-env (set-fp-env-register)
    set_ppc_fpu_env ;

M: ppc (fp-env-registers)
    <ppc-fpu-env> 1array ;

CONSTANT: ppc-exception-flag-bits HEX: 3e00,0000
CONSTANT: ppc-exception-flag>bit
    H{
        { +fp-invalid-operation+ HEX: 2000,0000 }
        { +fp-overflow+          HEX: 1000,0000 }
        { +fp-underflow+         HEX: 0800,0000 }
        { +fp-zero-divide+       HEX: 0400,0000 }
        { +fp-inexact+           HEX: 0200,0000 }
    }

CONSTANT: ppc-fp-traps-bits HEX: f80
CONSTANT: ppc-fp-traps>bit
    H{
        { +fp-invalid-operation+ HEX: 8000 }
        { +fp-overflow+          HEX: 4000 }
        { +fp-underflow+         HEX: 2000 }
        { +fp-zero-divide+       HEX: 1000 }
        { +fp-inexact+           HEX: 0800 }
    }

CONSTANT: ppc-rounding-mode-bits HEX: 3
CONSTANT: ppc-rounding-mode>bit
    $[ H{
        { +round-nearest+ HEX: 0 }
        { +round-zero+    HEX: 1 }
        { +round-up+      HEX: 2 }
        { +round-down+    HEX: 3 }
    } >biassoc ]

CONSTANT: ppc-denormal-mode-bits HEX: 4

M: ppc-fpu-env (get-exception-flags) ( register -- exceptions )
    fpcsr>> ppc-exception-flag>bit mask> ; inline
M: ppc-fpu-env (set-exception-flags) ( register exceptions -- register' )
    [ ppc-exception-flag>bit >mask ppc-exception-flag-bits remask ] curry change-fpcsr ; inline

M: ppc-fpu-env (get-fp-traps) ( register -- exceptions )
    fpcsr>> not ppc-fp-traps>bit mask> ; inline
M: ppc-fpu-env (set-fp-traps) ( register exceptions -- register' )
    [ ppc-fp-traps>bit >mask not ppc-fp-traps-bits remask ] curry change-fpcsr ; inline

M: ppc-fpu-env (get-rounding-mode) ( register -- mode )
    fpcsr>> ppc-rounding-mode-bits mask ppc-rounding-mode>bit value-at ; inline
M: ppc-fpu-env (set-rounding-mode) ( register mode -- register' )
    [ ppc-rounding-mode>bit at ppc-rounding-mode-bits remask ] curry change-fpcsr ; inline

M: ppc-fpu-env (get-denormal-mode) ( register -- mode )
    fpcsr>> ppc-denormal-mode-bits mask zero? +denormal-keep+ +denormal-flush+ ? ; inline
M: ppc-fpu-env (set-denormal-mode) ( register mode -- register' )
    [
        {
            { +denormal-keep+  [ ppc-denormal-mode-bits unmask ] }
            { +denormal-flush+ [ ppc-denormal-mode-bits bitor  ] }
        } case
    ] curry change-fpcsr ; inline

