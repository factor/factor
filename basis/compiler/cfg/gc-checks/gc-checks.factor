! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs
compiler.cfg.rpo compiler.cfg.instructions
compiler.cfg.hats ;
IN: compiler.cfg.gc-checks

: gc? ( bb -- ? )
    instructions>> [ ##allocation? ] any? ;

: insert-gc-check ( basic-block -- )
    dup gc? [
        [ i i f f \ ##gc new-insn prefix ] change-instructions drop
    ] [ drop ] if ;

: insert-gc-checks ( cfg -- cfg' )
    dup [ insert-gc-check ] each-basic-block ;