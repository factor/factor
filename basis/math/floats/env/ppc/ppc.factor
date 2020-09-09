USING: accessors alien alien.c-types alien.syntax arrays assocs
biassocs classes.struct combinators kernel literals math
math.bitwise math.floats.env math.floats.env.private system
cpu.ppc.assembler ;
IN: math.floats.env.ppc

STRUCT: ppc-fpu-env
    { padding uint }
    { fpscr uint } ;

STRUCT: ppc-vmx-env
    { vscr uint } ;

: get_ppc_fpu_env ( env -- )
    void { void* } cdecl [
        0 MFFS
        0 3 0 STFD
    ] alien-assembly ;

: set_ppc_fpu_env ( env -- )
    void { void* } cdecl [
        0 3 0 LFD
        0xff 0 0 0 MTFSF
    ] alien-assembly ;

: get_ppc_vmx_env ( env -- )
    void { void* } cdecl [
        0 MFVSCR
        4 1 16 SUBI
        5 0xf LI
        4 4 5 ANDC
        0 0 4 STVXL
        5 0xc LI
        6 5 4 LWZX
        6 3 0 STW
    ] alien-assembly ;

: set_ppc_vmx_env ( env -- )
    void { void* } cdecl [
        3 1 16 SUBI
        5 0xf LI
        4 4 5 ANDC
        5 0xc LI
        6 3 0 LWZ
        6 5 4 STWX
        0 0 4 LVXL
        0 MTVSCR
    ] alien-assembly ;

: <ppc-fpu-env> ( -- ppc-fpu-env )
    ppc-fpu-env (struct)
    [ get_ppc_fpu_env ] keep ;

: <ppc-vmx-env> ( -- ppc-fpu-env )
    ppc-vmx-env (struct)
    [ get_ppc_vmx_env ] keep ;

M: ppc-fpu-env (set-fp-env-register)
    set_ppc_fpu_env ;

M: ppc-vmx-env (set-fp-env-register)
    set_ppc_vmx_env ;

M: ppc (fp-env-registers)
    <ppc-fpu-env> 1array ;

CONSTANT: ppc-exception-flag-bits 0xfff8,0700
CONSTANT: ppc-exception-flag>bit
    H{
        { +fp-invalid-operation+ 0x2000,0000 }
        { +fp-overflow+          0x1000,0000 }
        { +fp-underflow+         0x0800,0000 }
        { +fp-zero-divide+       0x0400,0000 }
        { +fp-inexact+           0x0200,0000 }
    }

CONSTANT: ppc-fp-traps-bits 0xf8
CONSTANT: ppc-fp-traps>bit
    H{
        { +fp-invalid-operation+ 0x80 }
        { +fp-overflow+          0x40 }
        { +fp-underflow+         0x20 }
        { +fp-zero-divide+       0x10 }
        { +fp-inexact+           0x08 }
    }

CONSTANT: ppc-rounding-mode-bits 0x3
CONSTANT: ppc-rounding-mode>bit
    $[ H{
        { +round-nearest+ 0x0 }
        { +round-zero+    0x1 }
        { +round-up+      0x2 }
        { +round-down+    0x3 }
    } >biassoc ]

CONSTANT: ppc-denormal-mode-bits 0x4

M: ppc-fpu-env (get-exception-flags)
    fpscr>> ppc-exception-flag>bit mask> ; inline
M: ppc-fpu-env (set-exception-flags)
    [ ppc-exception-flag>bit >mask ppc-exception-flag-bits remask ] curry change-fpscr ; inline

M: ppc-fpu-env (get-fp-traps)
    fpscr>> ppc-fp-traps>bit mask> ; inline
M: ppc-fpu-env (set-fp-traps)
    [ ppc-fp-traps>bit >mask ppc-fp-traps-bits remask ] curry change-fpscr ; inline

M: ppc-fpu-env (get-rounding-mode)
    fpscr>> ppc-rounding-mode-bits mask ppc-rounding-mode>bit value-at ; inline
M: ppc-fpu-env (set-rounding-mode)
    [ ppc-rounding-mode>bit at ppc-rounding-mode-bits remask ] curry change-fpscr ; inline

M: ppc-fpu-env (get-denormal-mode)
    fpscr>> ppc-denormal-mode-bits mask zero? +denormal-keep+ +denormal-flush+ ? ; inline
M: ppc-fpu-env (set-denormal-mode)
    [
        {
            { +denormal-keep+  [ ppc-denormal-mode-bits unmask ] }
            { +denormal-flush+ [ ppc-denormal-mode-bits bitor  ] }
        } case
    ] curry change-fpscr ; inline

CONSTANT: vmx-denormal-mode-bits 0x10000

M: ppc-vmx-env (get-exception-flags)
    drop { } ; inline
M: ppc-vmx-env (set-exception-flags)
    drop ;

M: ppc-vmx-env (get-fp-traps)
    drop { } ; inline
M: ppc-vmx-env (set-fp-traps)
    drop ;

M: ppc-vmx-env (get-rounding-mode)
    drop +round-nearest+ ;
M: ppc-vmx-env (set-rounding-mode)
    drop ;

M: ppc-vmx-env (get-denormal-mode)
    vscr>> vmx-denormal-mode-bits mask zero? +denormal-keep+ +denormal-flush+ ? ; inline
M: ppc-vmx-env (set-denormal-mode)
    [
        {
            { +denormal-keep+  [ vmx-denormal-mode-bits unmask ] }
            { +denormal-flush+ [ vmx-denormal-mode-bits bitor  ] }
        } case
    ] curry change-vscr ; inline
