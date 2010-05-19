! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces accessors math math.order assocs kernel sequences
combinators classes words system cpu.architecture layouts compiler.cfg
compiler.cfg.rpo compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stack-frame ;
IN: compiler.cfg.build-stack-frame

SYMBOL: local-allot

SYMBOL: frame-required?

GENERIC: compute-stack-frame* ( insn -- )

: frame-required ( -- ) frame-required? on ;

: request-stack-frame ( stack-frame -- )
    frame-required
    stack-frame [ max-stack-frame ] change ;

M: ##local-allot compute-stack-frame*
    local-allot get >>offset
    size>> local-allot +@ ;

M: ##stack-frame compute-stack-frame*
    stack-frame>> request-stack-frame ;

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

: request-spill-area ( n -- )
    stack-frame new swap >>spill-area-size request-stack-frame ;

: request-local-allot ( n -- )
    stack-frame new swap >>local-allot request-stack-frame ;

: compute-stack-frame ( cfg -- )
    0 local-allot set
    stack-frame new stack-frame set
    [ spill-area-size>> [ request-spill-area ] unless-zero ]
    [ [ instructions>> [ compute-stack-frame* ] each ] each-basic-block ] bi
    local-allot get [ request-local-allot ] unless-zero
    stack-frame get dup stack-frame-size >>total-size drop ;

: build-stack-frame ( cfg -- cfg )
    [
        [ compute-stack-frame ]
        [
            frame-required? get stack-frame get f ?
            >>stack-frame
        ] bi
    ] with-scope ;
