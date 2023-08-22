! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays classes
classes.algebra classes.singleton classes.tuple
classes.tuple.private combinators combinators.short-circuit
compiler.tree.propagation.copy compiler.utilities kernel layouts math
math.intervals namespaces sequences sequences.private strings
words ;
IN: compiler.tree.propagation.info

: false-class? ( class -- ? ) \ f class<= ;

: true-class? ( class -- ? ) \ f class-not class<= ;

: null-class? ( class -- ? ) null class<= ;

GENERIC: eql? ( obj1 obj2 -- ? )
M: object eql? eq? ;
M: fixnum eql? eq? ;
M: bignum eql? over bignum? [ = ] [ 2drop f ] if ;
M: ratio eql? over ratio? [ = ] [ 2drop f ] if ;
M: float eql? over float? [ [ double>bits ] same? ] [ 2drop f ] if ;
M: complex eql? over complex? [ = ] [ 2drop f ] if ;

TUPLE: value-info-state
    class
    interval
    literal
    literal?
    slots ;

CONSTANT: null-info T{ value-info-state f null empty-interval }

CONSTANT: object-info T{ value-info-state f object full-interval }

: interval>literal ( class interval -- literal literal? )
    dup special-interval? [
        2drop f f
    ] [
        dup from>> first {
            { [ over interval-length 0 > ] [ 3drop f f ] }
            { [ pick bignum class<= ] [ 2nip >bignum t ] }
            { [ pick integer class<= ] [ 2nip >fixnum t ] }
            { [ pick float class<= ] [ 2nip [ f f ] [ >float t ] if-zero ] }
            [ 3drop f f ]
        } cond
    ] if ;

: <value-info> ( -- info ) \ value-info-state new ; inline

DEFER: <literal-info>

: tuple-slot-infos ( tuple -- slots )
    [ tuple-slots ] [ class-of all-slots ] bi
    [ read-only>> [ <literal-info> ] [ drop f ] if ] 2map
    f prefix ;

UNION: fixed-length array byte-array string ;

: literal-class ( obj -- class )
    dup singleton-class? [
        class-of dup class? [
            drop tuple
        ] unless
    ] unless ;

: (slots-with-length) ( length class -- slots )
    "slots" word-prop length 1 - f <array> swap prefix ;

: slots-with-length ( seq -- slots )
    [ length <literal-info> ] [ class-of ] bi (slots-with-length) ;

: init-literal-info ( info -- info )
    empty-interval >>interval
    dup literal>> literal-class >>class
    dup literal>> {
        { [ dup real? ] [ [a,a] >>interval ] }
        { [ dup tuple? ] [ tuple-slot-infos >>slots ] }
        { [ dup fixed-length? ] [ slots-with-length >>slots ] }
        [ drop ]
    } cond ; inline

: empty-set? ( info -- ? )
    {
        [ class>> null-class? ]
        [ { [ interval>> empty-interval? ] [ class>> real class<= ] } 1&& ]
    } 1|| ;

! Hardcoding classes is kind of a hack.
: min-value ( class -- n )
    {
        { fixnum [ most-negative-fixnum ] }
        { array-capacity [ 0 ] }
        { integer-array-capacity [ 0 ] }
        [ drop -1/0. ]
    } case ;

: max-value ( class -- n )
    {
        { fixnum [ most-positive-fixnum ] }
        { array-capacity [ max-array-capacity ] }
        { integer-array-capacity [ max-array-capacity ] }
        [ drop 1/0. ]
    } case ;

: class-interval ( class -- i )
    {
        { fixnum [ fixnum-interval ] }
        { array-capacity [ array-capacity-interval ] }
        { integer-array-capacity [ array-capacity-interval ] }
        [ drop full-interval ]
    } case ;

: fix-capacity-class ( class -- class' )
    {
        { array-capacity fixnum }
        { integer-array-capacity integer }
    } ?at drop ;

: wrap-interval ( interval class -- interval' )
    class-interval 2dup interval-subset? [ drop ] [ nip ] if ;

: init-interval ( info -- info )
    dup [ interval>> full-interval or ] [ class>> ] bi wrap-interval >>interval
    dup class>> integer class<= [ [ integral-closure ] change-interval ] when ; inline

: init-value-info ( info -- info )
    dup literal?>> [
        init-literal-info
    ] [
        dup empty-set? [
            null >>class
            empty-interval >>interval
        ] [
            init-interval
            dup [ class>> ] [ interval>> ] bi interval>literal
            [ >>literal ] [ >>literal? ] bi*
            [ fix-capacity-class ] change-class
        ] if
    ] if ; inline

: <class/interval-info> ( class interval -- info )
    <value-info>
        swap >>interval
        swap >>class
    init-value-info ; foldable

: <class-info> ( class -- info )
    f <class/interval-info> ; foldable

: <interval-info> ( interval -- info )
    <value-info>
        real >>class
        swap >>interval
    init-value-info ; foldable

: <literal-info> ( literal -- info )
    <value-info>
        swap >>literal
        t >>literal?
    init-value-info ; foldable

: <sequence-info> ( length class -- info )
    <value-info>
        over >>class
        [ (slots-with-length) ] dip swap >>slots
    init-value-info ;

: <tuple-info> ( slots class -- info )
    <value-info>
        swap >>class
        swap >>slots
    init-value-info ;

: >literal< ( info -- literal literal? )
    [ literal>> ] [ literal?>> ] bi ;

: intersect-literals ( info1 info2 -- literal literal? )
    {
        { [ dup literal?>> not ] [ drop >literal< ] }
        { [ over literal?>> not ] [ nip >literal< ] }
        { [ 2dup [ literal>> ] bi@ eql? not ] [ 2drop f f ] }
        [ drop >literal< ]
    } cond ;

DEFER: value-info-intersect

DEFER: (value-info-intersect)

: intersect-slot ( info1 info2 -- info )
    2dup and [ (value-info-intersect) ] [ 2drop f ] if ;

: intersect-slots ( info1 info2 -- slots )
    [ slots>> ] bi@ {
        { [ dup not ] [ drop ] }
        { [ over not ] [ nip ] }
        [
            2dup [ length ] same?
            [ [ intersect-slot ] 2map ] [ 2drop f ] if
        ]
    } cond ;

: (value-info-intersect) ( info1 info2 -- info )
    [ <value-info> ] 2dip
    {
        [ [ class>> ] bi@ class-and >>class ]
        [ [ interval>> ] bi@ interval-intersect >>interval ]
        [ intersect-literals [ >>literal ] [ >>literal? ] bi* ]
        [ intersect-slots >>slots ]
    } 2cleave
    init-value-info ;

: value-info-intersect ( info1 info2 -- info )
    {
        { [ dup class>> null-class? ] [ nip ] }
        { [ over class>> null-class? ] [ drop ] }
        [ (value-info-intersect) ]
    } cond ;

: union-literals ( info1 info2 -- literal literal? )
    2dup [ literal?>> ] both? [
        [ literal>> ] bi@ 2dup eql? [ drop t ] [ 2drop f f ] if
    ] [ 2drop f f ] if ;

DEFER: value-info-union

DEFER: (value-info-union)

: union-slot ( info1 info2 -- info )
    2dup and [ (value-info-union) ] [ 2drop f ] if ;

: union-slots ( info1 info2 -- slots )
    [ slots>> ] bi@
    2dup [ length ] same?
    [ [ union-slot ] 2map ] [ 2drop f ] if ;

: (value-info-union) ( info1 info2 -- info )
    [ <value-info> ] 2dip
    {
        [ [ class>> ] bi@ class-or >>class ]
        [ [ interval>> ] bi@ interval-union >>interval ]
        [ union-literals [ >>literal ] [ >>literal? ] bi* ]
        [ union-slots >>slots ]
    } 2cleave
    init-value-info ;

: value-info-union ( info1 info2 -- info )
    {
        { [ dup class>> null-class? ] [ drop ] }
        { [ over class>> null-class? ] [ nip ] }
        [ (value-info-union) ]
    } cond ;

: value-infos-union ( infos -- info )
    [ null-info ]
    [ [ ] [ value-info-union ] map-reduce ] if-empty ;

: literals<= ( info1 info2 -- ? )
    {
        { [ dup literal?>> not ] [ 2drop t ] }
        { [ over literal?>> not ] [ drop class>> null-class? ] }
        [ [ literal>> ] bi@ eql? ]
    } cond ;

DEFER: value-info<=

: slots<= ( info1 info2 -- ? )
    2dup [ class>> ] bi@ class< [ 2drop t ] [
        [ slots>> ] bi@ f pad-tail-shorter [ value-info<= ] 2all?
    ] if ;

: value-info<= ( info1 info2 -- ? )
    [ [ object-info ] unless* ] bi@
    {
        [ [ class>> ] bi@ class<= ]
        [ [ interval>> ] bi@ interval-subset? ]
        [ literals<= ]
        [ slots<= ]
    } 2&& ;

SYMBOL: value-infos

: value-info* ( value -- info ? )
    resolve-copy value-infos get assoc-stack
    [ null-info or ] [ >boolean ] bi ; inline

: value-info ( value -- info )
    value-info* drop ;

: (set-value-info) ( info value assoc -- )
    [ resolve-copy ] dip last set-at ;

: set-value-info ( info value -- )
    value-infos get (set-value-info) ;

: set-value-infos ( infos values -- )
    value-infos get '[ _ (set-value-info) ] 2each ;

: (refine-value-info) ( info value assoc -- )
    [ resolve-copy ] dip
    [ assoc-stack [ value-info-intersect ] when* ] 2keep
    last set-at ;

: refine-value-info ( info value -- )
    value-infos get (refine-value-info) ;

: refine-value-infos ( infos values -- )
    value-infos get '[ _ (refine-value-info) ] 2each ;

: value-literal ( value -- obj ? )
    value-info >literal< ;

: possible-boolean-values ( info -- values )
    class>> {
        { [ dup null-class? ] [ { } ] }
        { [ dup true-class? ] [ { t } ] }
        { [ dup false-class? ] [ { f } ] }
        [ { t f } ]
    } cond nip ;

: node-value-info ( node value -- info )
    swap info>> at* [ drop null-info ] unless ;

: node-input-infos ( node -- seq )
    dup in-d>> [ node-value-info ] with map ;

: node-output-infos ( node -- seq )
    dup out-d>> [ node-value-info ] with map ;

: first-literal ( #call -- obj )
    dup in-d>> first node-value-info literal>> ;

: last-literal ( #call -- obj )
    dup out-d>> last node-value-info literal>> ;

: immutable-tuple-boa? ( #call -- ? )
    dup word>> \ <tuple-boa> eq? [
        dup in-d>> last node-value-info
        literal>> first immutable-tuple-class?
    ] [ drop f ] if ;

: class-infos ( classes/f -- infos )
    [ <class-info> ] map ;

: word>input-infos ( word -- input-infos/f )
    "input-classes" word-prop class-infos ;
