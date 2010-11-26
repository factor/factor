! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs math accessors destructors fry sequences ;
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
    [ check-disposed ] keep
    [ <cache-entry> ] 2dip
    assoc>> set-at ;

M: cache-assoc clear-assoc
    [ assoc>> values dispose-each ]
    [ assoc>> clear-assoc ]
    bi ;

M: cache-assoc >alist assoc>> [ value>> ] { } assoc-map-as ;

INSTANCE: cache-assoc assoc

M: cache-assoc dispose* clear-assoc ;

PRIVATE>

: purge-cache ( cache -- )
    dup max-age>> '[
        [ nip [ 1 + ] change-age age>> _ < ] assoc-partition
        values dispose-each
    ] change-assoc drop ;
