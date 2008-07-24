! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs classes classes.algebra kernel accessors math
math.intervals namespaces sequences words combinators arrays
compiler.tree.copy-equiv ;
IN: compiler.tree.propagation.info

SYMBOL: +interval+

GENERIC: eql? ( obj1 obj2 -- ? )
M: object eql? eq? ;
M: fixnum eql? eq? ;
M: bignum eql? over bignum? [ = ] [ 2drop f ] if ;
M: ratio eql? over ratio? [ = ] [ 2drop f ] if ;
M: float eql? over float? [ [ double>bits ] bi@ = ] [ 2drop f ] if ;
M: complex eql? over complex? [ = ] [ 2drop f ] if ;

! Value info represents a set of objects. Don't mutate value infos
! you receive, always construct new ones. We don't declare the
! slots read-only to allow cloning followed by writing.
TUPLE: value-info
{ class initial: null }
{ interval initial: empty-interval }
literal
literal? ;

: class-interval ( class -- interval )
    dup real class<=
    [ +interval+ word-prop [-inf,inf] or ] [ drop f ] if ;

: interval>literal ( class interval -- literal literal? )
    #! If interval has zero length and the class is sufficiently
    #! precise, we can turn it into a literal
    dup empty-interval eq? [
        2drop f f
    ] [
        dup from>> first {
            { [ over interval-length 0 > ] [ 3drop f f ] }
            { [ pick bignum class<= ] [ 2nip >bignum t ] }
            { [ pick integer class<= ] [ 2nip >fixnum t ] }
            { [ pick float class<= ] [
                2nip dup zero? [ drop f f ] [ >float t ] if
            ] }
            [ 3drop f f ]
        } cond
    ] if ;

: <value-info> ( class interval literal literal? -- info )
    [
        2nip
        [ class ] [ dup real? [ [a,a] ] [ drop [-inf,inf] ] if ] [ ] tri
        t
    ] [
        drop
        2dup [ null class<= ] [ empty-interval eq? ] bi* or [
            2drop null empty-interval f f
        ] [
            over integer class<= [ integral-closure ] when
            2dup interval>literal
        ] if
    ] if
    \ value-info boa ; foldable

: <class/interval-info> ( class interval -- info )
    f f <value-info> ; foldable

: <class-info> ( class -- info )
    dup word? [ dup +interval+ word-prop ] [ f ] if [-inf,inf] or
    <class/interval-info> ; foldable

: <interval-info> ( interval -- info )
    real swap <class/interval-info> ; foldable

: <literal-info> ( literal -- info )
    f f rot t <value-info> ; foldable

: >literal< ( info -- literal literal? ) [ literal>> ] [ literal?>> ] bi ;

: intersect-literals ( info1 info2 -- literal literal? )
    {
        { [ dup literal?>> not ] [ drop >literal< ] }
        { [ over literal?>> not ] [ nip >literal< ] }
        { [ 2dup [ literal>> ] bi@ eql? not ] [ 2drop f f ] }
        [ drop >literal< ]
    } cond ;

: (value-info-intersect) ( info1 info2 -- info )
    [ [ class>> ] bi@ class-and ]
    [ [ interval>> ] bi@ interval-intersect ]
    [ intersect-literals ]
    2tri <value-info> ;

: value-info-intersect ( info1 info2 -- info )
    {
        { [ dup class>> null class<= ] [ nip ] }
        { [ over class>> null class<= ] [ drop ] }
        [ (value-info-intersect) ]
    } cond ;

: union-literals ( info1 info2 -- literal literal? )
    2dup [ literal?>> ] both? [
        [ literal>> ] bi@ 2dup eql? [ drop t ] [ 2drop f f ] if
    ] [ 2drop f f ] if ;

: (value-info-union) ( info1 info2 -- info )
    [ [ class>> ] bi@ class-or ]
    [ [ interval>> ] bi@ interval-union ]
    [ union-literals ]
    2tri <value-info> ;

: value-info-union ( info1 info2 -- info )
    {
        { [ dup class>> null class<= ] [ drop ] }
        { [ over class>> null class<= ] [ nip ] }
        [ (value-info-union) ]
    } cond ;

: value-infos-union ( infos -- info )
    dup first [ value-info-union ] reduce ;

! Current value --> info mapping
SYMBOL: value-infos

: value-info ( value -- info )
    resolve-copy value-infos get at T{ value-info } or ;

: set-value-info ( info value -- )
    resolve-copy value-infos get set-at ;

: refine-value-info ( info value -- )
    resolve-copy value-infos get [ value-info-intersect ] change-at ;

: value-literal ( value -- obj ? )
    value-info >literal< ;

: possible-boolean-values ( info -- values )
    dup literal?>> [
        literal>> 1array
    ] [
        class>> {
            { [ dup null class<= ] [ { } ] }
            { [ dup \ f class-not class<= ] [ { t } ] }
            { [ dup \ f class<= ] [ { f } ] }
            [ { t f } ]
        } cond nip
    ] if ;
