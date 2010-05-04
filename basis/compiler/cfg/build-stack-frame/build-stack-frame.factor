! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces accessors math.order assocs kernel sequences
combinators classes words cpu.architecture layouts compiler.cfg
compiler.cfg.rpo compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stack-frame ;
IN: compiler.cfg.build-stack-frame

SYMBOL: frame-required?

GENERIC: compute-stack-frame* ( insn -- )

: request-stack-frame ( stack-frame -- )
    frame-required? on
    stack-frame [ max-stack-frame ] change ;

UNION: stack-frame-insn
    ##alien-invoke
    ##alien-indirect
    ##alien-assembly
    ##alien-callback ;

M: stack-frame-insn compute-stack-frame*
    stack-frame>> request-stack-frame ;

M: ##call compute-stack-frame* drop frame-required? on ;

M: ##call-gc compute-stack-frame*
    drop
    frame-required? on
    stack-frame new t >>calls-vm? request-stack-frame ;

M: insn compute-stack-frame*
    class "frame-required?" word-prop
    [ frame-required? on ] when ;

: initial-stack-frame ( -- stack-frame )
    stack-frame new cfg get spill-area-size>> >>spill-area-size ;

: compute-stack-frame ( insns -- )
    frame-required? off
    initial-stack-frame stack-frame set
    [ instructions>> [ compute-stack-frame* ] each ] each-basic-block
    stack-frame get dup stack-frame-size >>total-size drop ;

: build-stack-frame ( cfg -- cfg )
    [
        [ compute-stack-frame ]
        [
            frame-required? get stack-frame get f ?
            >>stack-frame
        ] bi
    ] with-scope ;
