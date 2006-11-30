! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: arrays generic namespaces sequences math ;

: >c ( continuation -- ) catchstack* push ;
: c> ( -- continuation ) catchstack* pop ;

IN: errors
USING: kernel ;

SYMBOL: error
SYMBOL: error-continuation
SYMBOL: error-stack-trace
SYMBOL: restarts

: catch ( try -- error/f )
    [ >c call f c> drop f ] callcc1 nip ; inline

: rethrow ( error -- )
    catchstack* empty?
    [ die ] [ dup error set-global c> continue-with ] if ;

: cleanup ( try cleanup -- )
    [ >c >r call c> drop r> call ]
    [ >r nip call r> rethrow ] ifcc ;
    inline

: recover ( try recovery -- )
    [ >c drop call c> drop ]
    [ rot drop swap call ] ifcc ; inline

TUPLE: condition restarts continuation ;

C: condition ( error restarts cc -- condition )
    [ set-condition-continuation ] keep
    [ set-condition-restarts ] keep
    [ set-delegate ] keep ;

: condition ( error restarts -- restart )
    [ <condition> throw ] callcc1 2nip ;

TUPLE: restart name obj continuation ;

: restart ( restart -- )
    dup restart-obj swap restart-continuation continue-with ;

GENERIC: compute-restarts ( error -- seq )

M: object compute-restarts drop { } ;

M: tuple compute-restarts delegate compute-restarts ;

M: condition compute-restarts
    [ delegate compute-restarts ] keep
    [ condition-continuation ] keep
    condition-restarts [ first2 rot <restart> ] map-with
    append ;

PREDICATE: array kernel-error ( obj -- ? )
    dup first \ kernel-error eq? swap second 0 18 between? and ;

DEFER: try
