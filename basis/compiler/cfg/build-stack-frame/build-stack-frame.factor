! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces accessors math math.order assocs kernel sequences
combinators classes words system cpu.architecture layouts compiler.cfg
compiler.cfg.rpo compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stack-frame ;
IN: compiler.cfg.build-stack-frame

SYMBOL: frame-required?

GENERIC: compute-stack-frame* ( insn -- )

: request-stack-frame ( stack-frame -- )
    frame-required? on
    stack-frame [ max-stack-frame ] change ;

M: ##stack-frame compute-stack-frame*
    stack-frame>> request-stack-frame ;

: frame-required ( -- ) frame-required? on ;

: vm-frame-required ( -- )
    frame-required
    stack-frame new vm-stack-space >>params request-stack-frame ;

M: ##call-gc compute-stack-frame* drop vm-frame-required ;
M: ##box compute-stack-frame* drop vm-frame-required ;
M: ##unbox compute-stack-frame* drop vm-frame-required ;
M: ##box-long-long compute-stack-frame* drop vm-frame-required ;
M: ##begin-callback compute-stack-frame* drop vm-frame-required ;
M: ##end-callback compute-stack-frame* drop vm-frame-required ;
M: ##unary-float-function compute-stack-frame* drop vm-frame-required ;
M: ##binary-float-function compute-stack-frame* drop vm-frame-required ;

M: ##call compute-stack-frame* drop frame-required ;
M: ##alien-callback compute-stack-frame* drop frame-required ;
M: ##spill compute-stack-frame* drop frame-required ;
M: ##reload compute-stack-frame* drop frame-required ;

M: ##float>integer compute-stack-frame*
    drop integer-float-needs-stack-frame? [ frame-required ] when ;

M: ##integer>float compute-stack-frame*
    drop integer-float-needs-stack-frame? [ frame-required ] when ;

M: insn compute-stack-frame* drop ;

: initial-stack-frame ( -- stack-frame )
    stack-frame new cfg get spill-area-size>> >>spill-area-size ;

: compute-stack-frame ( cfg -- )
    initial-stack-frame stack-frame set
    [ spill-area-size>> 0 > frame-required? set ]
    [ [ instructions>> [ compute-stack-frame* ] each ] each-basic-block ] bi
    stack-frame get dup stack-frame-size >>total-size drop ;

: build-stack-frame ( cfg -- cfg )
    [
        [ compute-stack-frame ]
        [
            frame-required? get stack-frame get f ?
            >>stack-frame
        ] bi
    ] with-scope ;
