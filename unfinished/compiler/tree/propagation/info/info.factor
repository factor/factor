! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs classes classes.algebra kernel accessors math
math.intervals namespaces disjoint-sets sequences words
combinators ;
IN: compiler.tree.propagation.info

SYMBOL: +interval+

GENERIC: eql? ( obj1 obj2 -- ? )
M: object eql? eq? ;
M: number eql? [ [ class ] bi@ = ] [ number= ] 2bi and ;

! Disjoint set of copy equivalence
SYMBOL: copies

: is-copy-of ( val copy -- ) copies get equate ;

: are-copies-of ( vals copies -- ) [ is-copy-of ] 2each ;

: resolve-copy ( copy -- val ) copies get representative ;

: introduce-value ( val -- ) copies get add-atom ;

! Value info represents a set of objects. Don't mutate value infos
! you receive, always construct new ones. We don't declare the
! slots read-only to allow cloning followed by writing.
TUPLE: value-info
{ class initial: null }
interval
literal
literal? ;

: class-interval ( class -- interval )
    dup real class<=
    [ +interval+ word-prop [-inf,inf] or ] [ drop f ] if ;

: interval>literal ( class interval -- literal literal? )
    dup from>> first {
        { [ over interval-length 0 > ] [ 3drop f f ] }
        { [ over from>> second not ] [ 3drop f f ] }
        { [ over to>> second not ] [ 3drop f f ] }
        { [ pick fixnum class<= ] [ 2nip >fixnum t ] }
        { [ pick bignum class<= ] [ 2nip >bignum t ] }
        { [ pick float class<= ] [ 2nip >float t ] }
        [ 3drop f f ]
    } cond ;

: <value-info> ( class interval literal literal? -- info )
    [
        2nip
        [ class ]
        [ dup real? [ [a,a] ] [ drop [-inf,inf] ] if ]
        [ ]
        tri t
    ] [
        drop
        over null class<= [ drop f f f ] [
            over integer class<= [ integral-closure ] when
            2dup interval>literal
        ] if
    ] if
    \ value-info boa ; foldable

: <class-info> ( class -- info )
    [-inf,inf] f f <value-info> ; foldable

: <interval-info> ( interval -- info )
    real swap f f <value-info> ; foldable

: <literal-info> ( literal -- info )
    f [-inf,inf] rot t <value-info> ; foldable

: >literal< ( info -- literal literal? ) [ literal>> ] [ literal?>> ] bi ;

: intersect-literals ( info1 info2 -- literal literal? )
    {
        { [ dup literal?>> not ] [ drop >literal< ] }
        { [ over literal?>> not ] [ nip >literal< ] }
        { [ 2dup [ literal>> ] bi@ eql? not ] [ 2drop f f ] }
        [ drop >literal< ]
    } cond ;

: interval-intersect' ( i1 i2 -- i3 )
    #! Change core later.
    2dup and [ interval-intersect ] [ 2drop f ] if ;

: value-info-intersect ( info1 info2 -- info )
    [ [ class>> ] bi@ class-and ]
    [ [ interval>> ] bi@ interval-intersect' ]
    [ intersect-literals ]
    2tri <value-info> ;

: interval-union' ( i1 i2 -- i3 )
    {
        { [ dup not ] [ drop ] }
        { [ over not ] [ nip ] }
        [ interval-union ]
    } cond ;

: union-literals ( info1 info2 -- literal literal? )
    2dup [ literal?>> ] both? [
        [ literal>> ] bi@ 2dup eql? [ drop t ] [ 2drop f f ] if
    ] [ 2drop f f ] if ;

: value-info-union ( info1 info2 -- info )
    [ [ class>> ] bi@ class-or ]
    [ [ interval>> ] bi@ interval-union' ]
    [ union-literals ]
    2tri <value-info> ;

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
