! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math layouts make sequences
cpu.architecture namespaces compiler.cfg
compiler.cfg.instructions ;
IN: compiler.cfg.utilities

: value-info-small-tagged? ( value-info -- ? )
    literal>> dup fixnum? [ tag-fixnum small-enough? ] [ drop f ] if ;

: set-basic-block ( basic-block -- )
    [ basic-block set ] [ instructions>> building set ] bi ;

: begin-basic-block ( -- )
    <basic-block> basic-block get [
        dupd successors>> push
    ] when*
    set-basic-block ;

: end-basic-block ( -- )
    building off
    basic-block off ;

: emit-primitive ( node -- )
    word>> ##call begin-basic-block ;

: need-gc ( -- ) basic-block get t >>gc drop ;
