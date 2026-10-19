! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.algebra compiler.cfg.instructions
compiler.cfg.linearization compiler.cfg.stack-frame
cpu.architecture kernel layouts math math.order namespaces
sequences ;
IN: compiler.cfg.build-stack-frame

SYMBOLS: param-area-size allot-area-size allot-area-align ;

GENERIC: compute-stack-frame* ( insn -- ? )

M:: ##local-allot compute-stack-frame* ( insn -- ? )
    insn size>> :> s
    insn align>> :> a
    allot-area-align [ a max ] change
    allot-area-size [ a align [ insn offset<< ] [ s + ] bi ] change t ;

M: alien-call-insn compute-stack-frame*
    stack-size>> param-area-size [ max ] change t ;

: vm-frame-required ( -- ? )
    vm-stack-space param-area-size [ max ] change t ;

M: ##call-gc compute-stack-frame* drop vm-frame-required ;
M: native-helper-insn compute-stack-frame* drop vm-frame-required ;
M: ##box compute-stack-frame* drop vm-frame-required ;
M: ##unbox compute-stack-frame* drop vm-frame-required ;
M: ##box-long-long compute-stack-frame* drop vm-frame-required ;
M: ##callback-inputs compute-stack-frame* drop vm-frame-required ;
M: ##callback-outputs compute-stack-frame* drop vm-frame-required ;

M: ##call compute-stack-frame* drop t ;
M: ##spill compute-stack-frame* drop t ;
M: ##reload compute-stack-frame* drop t ;

UNION: rounded-float-insn
    ##add-float ##sub-float ##mul-float ##div-float ##sqrt
    ##double>single-float ;

M: rounded-float-insn compute-stack-frame*
    drop float-arithmetic-stack-space dup zero?
    [ drop f ] [ param-area-size [ max ] change t ] if ;

M: ##float>integer compute-stack-frame*
    drop integer-float-needs-stack-frame? ;

M: ##integer>float compute-stack-frame*
    drop integer-float-needs-stack-frame? ;

M: insn compute-stack-frame* drop f ;

: calculate-allot-area-base ( stack-frame -- n )
    [ params>> ] [ allot-area-align>> ] bi align ;

: calculate-spill-area-base ( stack-frame -- n )
    [ allot-area-base>> ]
    [ allot-area-size>> + ]
    [ spill-area-align>> ] tri align ;

ERROR: stack-frame-too-large size max ;

: check-stack-frame-size ( n -- n )
    dup max-stack-frame-size > [
        dup max-stack-frame-size stack-frame-too-large
    ] when ;

: finalize-stack-frame ( stack-frame -- stack-frame )
    dup calculate-allot-area-base >>allot-area-base
    dup calculate-spill-area-base >>spill-area-base
    dup stack-frame-size check-stack-frame-size >>total-size ;

: compute-stack-frame ( cfg -- stack-frame/f )
    ! An empty CFG has no instructions that can use the register window.
    dup cfg>insns dup empty? not register-window-frame-required? and
    [ compute-stack-frame* or ] reduce [
        stack-frame>>
        allot-area-size get >>allot-area-size
        allot-area-align get >>allot-area-align
        param-area-size get >>params
        finalize-stack-frame
    ] [ drop f ] if ;

: build-stack-frame ( cfg -- )
    0 param-area-size set
    0 allot-area-size set
    cell allot-area-align set
    [ compute-stack-frame ] keep stack-frame<< ;
