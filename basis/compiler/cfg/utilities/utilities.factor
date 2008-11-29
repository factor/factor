! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math layouts make sequences combinators
cpu.architecture namespaces compiler.cfg
compiler.cfg.instructions ;
IN: compiler.cfg.utilities

: value-info-small-fixnum? ( value-info -- ? )
    literal>> {
        { [ dup fixnum? ] [ tag-fixnum small-enough? ] }
        [ drop f ]
    } cond ;

: value-info-small-tagged? ( value-info -- ? )
    dup literal?>> [
        literal>> {
            { [ dup fixnum? ] [ tag-fixnum small-enough? ] }
            { [ dup not ] [ drop t ] }
            [ drop f ]
        } cond
    ] [ drop f ] if ;

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

: stop-iterating ( -- next ) end-basic-block f ;

: emit-primitive ( node -- )
    word>> ##call ##branch begin-basic-block ;
