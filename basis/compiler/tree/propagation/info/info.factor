! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs classes classes.algebra classes.tuple
classes.tuple.private classes.singleton kernel accessors math
math.intervals namespaces sequences sequences.private words
combinators memoize combinators.short-circuit byte-arrays
strings arrays layouts cpu.architecture
compiler.tree.propagation.copy ;
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

! Value info represents a set of objects. Don't mutate value infos
! you receive, always construct new ones. We don't declare the
! slots read-only to allow cloning followed by writing, and to
! simplify constructors.
TUPLE: value-info
class
interval
literal
literal?
slots ;

CONSTANT: null-info T{ value-info f null empty-interval }

CONSTANT: object-info T{ value-info f object full-interval }

: interval>literal ( class interval -- literal literal? )
    #! If interval has zero length and the class is sufficiently
    #! precise, we can turn it into a literal
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

: <value-info> ( -- info ) \ value-info new ;

DEFER: <literal-info>

: tuple-slot-infos ( tuple -- slots )
    [ tuple-slots ] [ class-of all-slots ] bi
    [ read-only>> [ <literal-info> ] [ drop f ] if ] 2map
    f prefix ;

UNION: fixed-length array byte-array string ;

: literal-class ( obj -- class )
    #! Handle forgotten tuples and singleton classes properly
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
        [ [ interval>> empty-interval eq? ] [ class>> real class<= ] bi and ]
    } 1|| ;

: min-value ( class -- n )
    {
        { fixnum [ most-negative-fixnum ] }
        { array-capacity [ 0 ] }
        [ drop -1/0. ]
    } case ;

: max-value ( class -- n )
    {
        { fixnum [ most-positive-fixnum ] }
        { array-capacity [ max-array-capacity ] }
        [ drop 1/0. ]
    } case ;

: class-interval ( class -- i )
    {
        { fixnum [ fixnum-interval ] }
        { array-capacity [ array-capacity-interval ] }
        [ drop full-interval ]
    } case ;

: wrap-interval ( interval class -- interval' )
    {
        { [ over empty-interval eq? ] [ drop ] }
        { [ over full-interval eq? ] [ nip class-interval ] }
        { [ 2dup class-interval interval-subset? not ] [ nip class-interval ] }
        [ drop ]
    } cond ;

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
    {
        { [ dup not ] [ nip ] }
        { [ over not ] [ drop ] }
        [ (value-info-intersect) ]
    } cond ;

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
    {
        { [ dup not ] [ nip ] }
        { [ over not ] [ drop ] }
        [ (value-info-union) ]
    } cond ;

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

: value-info<= ( info1 info2 -- ? )
    {
        { [ dup not ] [ 2drop t ] }
        { [ over not ] [ 2drop f ] }
        [
            {
                { [ 2dup [ class>> ] bi@ class<= not ] [ f ] }
                { [ 2dup [ interval>> ] bi@ interval-subset? not ] [ f ] }
                { [ 2dup literals<= not ] [ f ] }
                { [ 2dup [ slots>> ] bi@ [ value-info<= ] 2all? not ] [ f ] }
                [ t ]
            } cond 2nip
        ]
    } cond ;

! Assoc stack of current value --> info mapping
SYMBOL: value-infos

: value-info* ( value -- info ? )
    resolve-copy value-infos get assoc-stack [ null-info or ] [ >boolean ] bi ; inline

: value-info ( value -- info )
    value-info* drop ;

: set-value-info ( info value -- )
    resolve-copy value-infos get last set-at ;

: refine-value-info ( info value -- )
    resolve-copy value-infos get
    [ assoc-stack [ value-info-intersect ] when* ] 2keep
    last set-at ;

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
