! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs classes classes.algebra kernel
accessors math math.intervals namespaces sequences words
combinators arrays compiler.tree.copy-equiv ;
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
! slots read-only to allow cloning followed by writing, and to
! simplify constructors.
TUPLE: value-info
class
interval
literal
literal?
length
slots ;

: null-info T{ value-info f null empty-interval } ; inline

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

: <value-info> ( -- info ) \ value-info new ;

: init-value-info ( info -- info )
    dup literal?>> [
        dup literal>> class >>class
        dup literal>> dup real? [ [a,a] ] [ drop [-inf,inf] ] if >>interval
    ] [
        dup [ class>> null class<= ] [ interval>> empty-interval eq? ] bi or [
            null >>class
            empty-interval >>interval
        ] [
            [ [-inf,inf] or ] change-interval
            dup class>> integer class<= [ [ integral-closure ] change-interval ] when
            dup [ class>> ] [ interval>> ] bi interval>literal
            [ >>literal ] [ >>literal? ] bi*
        ] if
    ] if ;

: <class/interval-info> ( class interval -- info )
    <value-info>
        swap >>interval
        swap >>class
    init-value-info ; foldable

: <class-info> ( class -- info )
    dup word? [ dup +interval+ word-prop ] [ f ] if [-inf,inf] or
    <class/interval-info> ; foldable

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

: <sequence-info> ( value -- info )
    <value-info>
        object >>class
        swap value-info >>length
    init-value-info ; foldable

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

: intersect-lengths ( info1 info2 -- length )
    [ length>> ] bi@ {
        { [ dup not ] [ drop ] }
        { [ over not ] [ nip ] }
        [ value-info-intersect ]
    } cond ;

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
            2dup [ length ] bi@ =
            [ [ intersect-slot ] 2map ] [ 2drop f ] if
        ]
    } cond ;

: (value-info-intersect) ( info1 info2 -- info )
    [ <value-info> ] 2dip
    {
        [ [ class>> ] bi@ class-and >>class ]
        [ [ interval>> ] bi@ interval-intersect >>interval ]
        [ intersect-literals [ >>literal ] [ >>literal? ] bi* ]
        [ intersect-lengths >>length ]
        [ intersect-slots >>slots ]
    } 2cleave
    init-value-info ;

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

DEFER: value-info-union

DEFER: (value-info-union)

: union-lengths ( info1 info2 -- length )
    [ length>> ] bi@ {
        { [ dup not ] [ nip ] }
        { [ over not ] [ drop ] }
        [ value-info-union ]
    } cond ;

: union-slot ( info1 info2 -- info )
    {
        { [ dup not ] [ nip ] }
        { [ over not ] [ drop ] }
        [ (value-info-union) ]
    } cond ;

: union-slots ( info1 info2 -- slots )
    [ slots>> ] bi@
    2dup [ length ] bi@ =
    [ [ union-slot ] 2map ] [ 2drop f ] if ;

: (value-info-union) ( info1 info2 -- info )
    [ <value-info> ] 2dip
    {
        [ [ class>> ] bi@ class-or >>class ]
        [ [ interval>> ] bi@ interval-union >>interval ]
        [ union-literals [ >>literal ] [ >>literal? ] bi* ]
        [ union-lengths >>length ]
        [ union-slots >>slots ]
    } 2cleave
    init-value-info ;

: value-info-union ( info1 info2 -- info )
    {
        { [ dup class>> null class<= ] [ drop ] }
        { [ over class>> null class<= ] [ nip ] }
        [ (value-info-union) ]
    } cond ;

: value-infos-union ( infos -- info )
    dup empty?
    [ drop null-info ]
    [ dup first [ value-info-union ] reduce ] if ;

! Current value --> info mapping
SYMBOL: value-infos

: value-info ( value -- info )
    resolve-copy value-infos get at null-info or ;

: set-value-info ( info value -- )
    resolve-copy value-infos get set-at ;

: refine-value-info ( info value -- )
    resolve-copy value-infos get [ value-info-intersect ] change-at ;

: value-literal ( value -- obj ? )
    value-info >literal< ;

: false-class? ( class -- ? ) \ f class<= ;

: true-class? ( class -- ? ) \ f class-not class<= ;

: possible-boolean-values ( info -- values )
    dup literal?>> [
        literal>> 1array
    ] [
        class>> {
            { [ dup null class<= ] [ { } ] }
            { [ dup true-class? ] [ { t } ] }
            { [ dup false-class? ] [ { f } ] }
            [ { t f } ]
        } cond nip
    ] if ;

: node-value-info ( node value -- info )
    swap info>> at* [ drop null-info ] unless ;

: node-input-infos ( node -- seq )
    dup in-d>> [ node-value-info ] with map ;

: node-output-infos ( node -- seq )
    dup out-d>> [ node-value-info ] with map ;
