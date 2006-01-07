! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: errors
USING: kernel kernel-internals lists sequences ;

TUPLE: no-method object generic ;

: no-method ( object generic -- ) <no-method> throw ;

: >c ( continuation -- ) catchstack* push ;
: c> ( -- continuation ) catchstack* pop ;

: catch ( try -- error | try: -- )
    [ >c call f c> drop f ] callcc1 nip ; inline

: cleanup ( try cleanup -- | try: -- | cleanup: -- )
    [ >c >r call c> drop r> call ]
    [ drop (continue-with) >r nip call r> rethrow ] ifcc ;
    inline

: recover ( try recovery -- | try: -- | recovery: error -- )
    [ >c drop call c> drop ]
    [ drop (continue-with) rot drop swap call ] ifcc ; inline

: rethrow ( error -- )
    catchstack* empty?
    [ die "Can't happen" throw ] [ c> continue-with ] if ;

GENERIC: error. ( error -- )
