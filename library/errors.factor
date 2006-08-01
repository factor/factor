! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: generic namespaces sequences ;

: >c ( continuation -- ) catchstack* push ;
: c> ( -- continuation ) catchstack* pop ;

IN: errors
USING: kernel ;

: catch ( try -- error | try: -- )
    [ >c call f c> drop f ] callcc1 nip ; inline

: rethrow ( error -- )
    catchstack* empty? [
        die
    ] [
        dup error set-global
        c> dup quotation? [ call ] [ continue-with ] if
    ] if ;

: cleanup ( try cleanup -- | try: -- | cleanup: -- )
    [ >c >r call c> drop r> call ]
    [ drop (continue-with) >r nip call r> rethrow ] ifcc ;
    inline

: recover ( try recovery -- | try: -- | recovery: error -- )
    [ >c drop call c> drop ]
    [ drop (continue-with) rot drop swap call ] ifcc ; inline

TUPLE: condition restarts cc ;

C: condition ( error restarts cc -- condition )
    [ set-condition-cc ] keep
    [ set-condition-restarts ] keep
    [ set-delegate ] keep ;

: condition ( error restarts -- restart )
    [ <condition> throw ] callcc1 2nip ;

GENERIC: compute-restarts

M: object compute-restarts drop { } ;

M: tuple compute-restarts delegate compute-restarts ;

M: condition compute-restarts
    [ delegate compute-restarts ] keep
    [ condition-cc ] keep
    condition-restarts [ swap add ] map-with append ;
