! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors words kernel sequences splitting ;
IN: furnace.utilities

: word>string ( word -- string )
    [ vocabulary>> ] [ name>> ] bi ":" swap 3append ;

: words>strings ( seq -- seq' )
    [ word>string ] map ;

ERROR: no-such-word name vocab ;

: string>word ( string -- word )
    ":" split1 swap 2dup lookup dup
    [ 2nip ] [ drop no-such-word ] if ;

: strings>words ( seq -- seq' )
    [ string>word ] map ;
