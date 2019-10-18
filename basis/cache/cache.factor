! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations destructors fry kernel
make math sequences ;
IN: cache

TUPLE: cache-assoc < disposable assoc max-age ;

: <cache-assoc> ( -- cache )
    cache-assoc new-disposable H{ } clone >>assoc 10 >>max-age ;

<PRIVATE

TUPLE: cache-entry value age ;

: <cache-entry> ( value -- entry ) 0 cache-entry boa ; inline

M: cache-entry dispose value>> dispose ;

M: cache-assoc assoc-size assoc>> assoc-size ;

M: cache-assoc at* assoc>> at* [ dup [ 0 >>age value>> ] when ] dip ;

M: cache-assoc set-at
    check-disposed
    [ <cache-entry> ] 2dip
    assoc>> set-at ;

M: cache-assoc clear-assoc
    assoc>> [ values dispose-each ] [ clear-assoc ] bi ;

M: cache-assoc >alist assoc>> [ value>> ] { } assoc-map-as ;

INSTANCE: cache-assoc assoc

M: cache-assoc dispose* clear-assoc ;

PRIVATE>

: purge-cache ( cache -- )
    [ assoc>> ] [ max-age>> ] bi V{ } clone [
        '[
            nip dup age>> 1 + [ >>age ] keep
            _ < [ drop t ] [ _ dispose-to f ] if
        ] assoc-filter! drop
    ] keep [ last rethrow ] unless-empty ;
