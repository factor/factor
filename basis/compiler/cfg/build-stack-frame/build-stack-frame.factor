! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.stack-frame cpu.architecture kernel layouts locals
math math.order namespaces sequences ;
IN: compiler.cfg.build-stack-frame

SYMBOLS: param-area-size allot-area-size allot-area-align
frame-required? ;

: frame-required ( -- ) frame-required? on ;

GENERIC: compute-stack-frame* ( insn -- )

M:: ##local-allot compute-stack-frame* ( insn -- )
    frame-required
    insn size>> :> s
    insn align>> :> a
    allot-area-align [ a max ] change
    allot-area-size [ a align [ insn offset<< ] [ s + ] bi ] change ;

M: alien-call-insn compute-stack-frame*
    frame-required
    stack-size>> param-area-size [ max ] change ;

: vm-frame-required ( -- )
    frame-required
    vm-stack-space param-area-size [ max ] change ;

M: ##call-gc compute-stack-frame* drop vm-frame-required ;
M: ##box compute-stack-frame* drop vm-frame-required ;
M: ##unbox compute-stack-frame* drop vm-frame-required ;
M: ##box-long-long compute-stack-frame* drop vm-frame-required ;
M: ##callback-inputs compute-stack-frame* drop vm-frame-required ;
M: ##callback-outputs compute-stack-frame* drop vm-frame-required ;

M: ##call compute-stack-frame* drop frame-required ;
M: ##spill compute-stack-frame* drop frame-required ;
M: ##reload compute-stack-frame* drop frame-required ;

M: ##float>integer compute-stack-frame*
    drop integer-float-needs-stack-frame? [ frame-required ] when ;

M: ##integer>float compute-stack-frame*
    drop integer-float-needs-stack-frame? [ frame-required ] when ;

M: insn compute-stack-frame* drop ;

: calculate-allot-area-base ( stack-frame -- n )
    [ params>> ] [ allot-area-align>> ] bi align ;

: calculate-spill-area-base ( stack-frame -- n )
    [ allot-area-base>> ]
    [ allot-area-size>> + ]
    [ spill-area-align>> ] tri align ;

: finalize-stack-frame ( stack-frame -- stack-frame )
    dup calculate-allot-area-base >>allot-area-base
    dup calculate-spill-area-base >>spill-area-base
    dup stack-frame-size >>total-size ;

: <stack-frame> ( cfg -- stack-frame )
    stack-frame new
        over spill-area-size>> >>spill-area-size
        swap spill-area-align>> >>spill-area-align
        allot-area-size get >>allot-area-size
        allot-area-align get >>allot-area-align
        param-area-size get >>params
        finalize-stack-frame ;

: compute-stack-frame ( cfg -- stack-frame/f )
    [ [ instructions>> [ compute-stack-frame* ] each ] each-basic-block ]
    [ frame-required? get [ <stack-frame> ] [ drop f ] if ]
    bi ;

: build-stack-frame ( cfg -- )
    f frame-required? set
    0 param-area-size set
    0 allot-area-size set
    cell allot-area-align set
    [ compute-stack-frame ] keep stack-frame<< ;
