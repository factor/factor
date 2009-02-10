! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs math accessors destructors fry ;
IN: cache

SLOT: age

GENERIC: age ( obj -- )

M: object age [ 1+ ] change-age drop ;

TUPLE: cache-assoc assoc max-age disposed ;

: <cache-assoc> ( -- cache )
    H{ } clone 10 f cache-assoc boa ;

M: cache-assoc assoc-size assoc>> assoc-size ;

M: cache-assoc at* assoc>> at* [ dup [ 0 >>age ] when ] dip ;

M: cache-assoc set-at dup check-disposed assoc>> set-at ;

M: cache-assoc clear-assoc assoc>> clear-assoc ;

M: cache-assoc >alist assoc>> >alist ;

INSTANCE: cache-assoc assoc

: purge-cache ( cache -- )
    dup max-age>> '[
        [ nip dup age age>> _ >= ] assoc-partition
        [ values dispose-each ] dip
    ] change-assoc drop ;

M: cache-assoc dispose*
    assoc>> [ values dispose-each ] [ clear-assoc ] bi ;
