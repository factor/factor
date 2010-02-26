! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel fry vectors accessors namespaces assocs sets
stack-checker.branches compiler.tree compiler.tree.def-use ;
FROM: namespaces => set ;
IN: compiler.tree.def-use.simplified

! Simplified def-use follows chains of copies.

! A 'real' usage is a usage of a value that is not a #renaming.
TUPLE: real-usage value node ;

<PRIVATE

SYMBOLS: visited accum ;

: if-not-visited ( value quot -- )
    over visited get key?
    [ 2drop ] [ over visited get conjoin call ] if ; inline

: with-simplified-def-use ( quot -- real-usages )
    [
        H{ } clone visited set
        H{ } clone accum set
        call
        accum get keys
    ] with-scope ; inline

PRIVATE>

! Def
GENERIC: actually-defined-by* ( value node -- )

: (actually-defined-by) ( value -- )
    [ dup defined-by actually-defined-by* ] if-not-visited ;

M: #renaming actually-defined-by*
    inputs/outputs swap [ index ] dip nth (actually-defined-by) ;

M: #call-recursive actually-defined-by*
    [ out-d>> index ] [ label>> return>> in-d>> nth ] bi
    (actually-defined-by) ;

M: #enter-recursive actually-defined-by*
    [ out-d>> index ] keep
    [ in-d>> nth (actually-defined-by) ]
    [ label>> calls>> [ node>> in-d>> nth (actually-defined-by) ] with each ] 2bi ;

M: #phi actually-defined-by*
    [ out-d>> index ] [ phi-in-d>> ] bi
    [
        nth dup +bottom+ eq?
        [ drop ] [ (actually-defined-by) ] if
    ] with each ;

M: node actually-defined-by*
    real-usage boa accum get conjoin ;

: actually-defined-by ( value -- real-usages )
    [ (actually-defined-by) ] with-simplified-def-use ;

! Use
GENERIC: actually-used-by* ( value node -- )

: (actually-used-by) ( value -- )
    [ dup used-by [ actually-used-by* ] with each ] if-not-visited ;

M: #renaming actually-used-by*
    inputs/outputs [ indices ] dip nths
    [ (actually-used-by) ] each ;

M: #return-recursive actually-used-by*
    [ in-d>> index ] keep
    [ out-d>> nth (actually-used-by) ]
    [ label>> calls>> [ node>> out-d>> nth (actually-used-by) ] with each ] 2bi ;

M: #call-recursive actually-used-by*
    [ in-d>> index ] [ label>> enter-out>> nth ] bi
    (actually-used-by) ;

M: #enter-recursive actually-used-by*
    [ in-d>> index ] [ out-d>> nth ] bi (actually-used-by) ;

M: #phi actually-used-by*
    [ phi-in-d>> [ index ] with map-find drop ] [ out-d>> nth ] bi
    (actually-used-by) ;

M: #recursive actually-used-by* 2drop ;

M: node actually-used-by*
    real-usage boa accum get conjoin ;

: actually-used-by ( value -- real-usages )
    [ (actually-used-by) ] with-simplified-def-use ;
