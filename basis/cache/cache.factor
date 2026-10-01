! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations destructors kernel locals math
sequences system ;
IN: cache

TUPLE: cache-assoc < disposable assoc max-age ;

: <cache-assoc> ( -- cache )
    cache-assoc new-disposable H{ } clone >>assoc 10 >>max-age ;

TUPLE: timed-cache-assoc < cache-assoc clock ;

: <timed-cache-assoc> ( -- cache )
    timed-cache-assoc new-disposable H{ } clone >>assoc
        10,000,000,000 >>max-age [ nano-count ] >>clock ;

<PRIVATE

TUPLE: cache-entry value age ;

GENERIC: cache-age ( cache -- age )

M: cache-assoc cache-age drop 0 ;
M: timed-cache-assoc cache-age clock>> call( -- ns ) ;

M: cache-entry dispose value>> dispose ;

M: cache-assoc assoc-size assoc>> assoc-size ;

M: cache-assoc at*
    [ assoc>> at* ] [ cache-age ] bi swap
    [ >>age value>> t ] [ 2drop f f ] if ;

M:: cache-assoc set-at ( value key cache -- )
    cache check-disposed drop
    value cache cache-age cache-entry boa key cache assoc>> set-at ;

M: cache-assoc delete-at
    assoc>> delete-at* drop [ dispose ] when* ;

M: cache-assoc clear-assoc
    assoc>> [ values dispose-each ] [ clear-assoc ] bi ;

M: cache-assoc >alist assoc>> [ value>> ] { } assoc-map-as ;

INSTANCE: cache-assoc assoc

M: cache-assoc dispose* clear-assoc ;

:: (purge-cache) ( cache live?: ( entry -- ? ) -- )
    V{ } clone :> errors
    cache cache assoc>> [| entry |
        entry live? call [ t ] [ entry errors dispose-to f ] if
    ] filter-values >>assoc drop
    errors [ last rethrow ] unless-empty ;

PRIVATE>

GENERIC: purge-cache ( cache -- )

M: cache-assoc purge-cache
    dup max-age>> '[
        dup age>> 1 + [ >>age ] keep _ < nip
    ] (purge-cache) ;

M: timed-cache-assoc purge-cache
    dup [ cache-age ] [ max-age>> ] bi -
    '[ age>> _ > ] (purge-cache) ;
