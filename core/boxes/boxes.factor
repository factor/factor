! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: boxes

TUPLE: box value full? ;

: <box> ( -- box ) box construct-empty ;

: >box ( value box -- )
    dup box-full? [ "Box already has a value" throw ] when
    t over set-box-full?
    set-box-value ;

: box> ( box -- value )
    dup box-full? [ "Box empty" throw ] unless
    dup box-value f pick set-box-value
    f rot set-box-full? ;

: ?box ( box -- value/f ? )
    dup box-full? [ box> t ] [ drop f f ] if ;

: if-box? ( box quot -- )
    >r ?box r> [ drop ] if ; inline
