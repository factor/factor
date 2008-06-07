! Based on Clojure's PersistentVector by Rich Hickey.

USING: math accessors kernel sequences.private sequences arrays
combinators parser prettyprint.backend ;
IN: persistent-vectors

ERROR: empty-error pvec ;

GENERIC: ppush ( val seq -- seq' )

M: sequence ppush swap suffix ;

GENERIC: ppop ( seq -- seq' )

M: sequence ppop 1 head* ;

GENERIC: new-nth ( val i seq -- seq' )

M: sequence new-nth clone [ set-nth ] keep ;

TUPLE: persistent-vector count root tail ;

M: persistent-vector length count>> ;

<PRIVATE

TUPLE: node children level ;

: node-size 32 ; inline

: node-mask node-size mod ; inline

: node-shift -5 * shift ; inline

: node-nth ( i node -- obj )
    [ node-mask ] [ children>> ] bi* nth ; inline

: body-nth ( i node -- i node' )
    dup level>> [
        dupd [ level>> node-shift ] keep node-nth
    ] times ; inline

: tail-offset ( pvec -- n )
    [ count>> ] [ tail>> children>> length ] bi - ;

M: persistent-vector nth-unsafe
    2dup tail-offset >=
    [ tail>> ] [ root>> body-nth ] if
    node-nth ;

: node-add ( val node -- node' )
    clone [ ppush ] change-children ;

: ppush-tail ( val pvec -- pvec' )
    [ node-add ] change-tail ;

: full? ( node -- ? )
    children>> length node-size = ;

: 1node ( val level -- node )
    node new
        swap >>level
        swap 1array >>children ;

: 2node ( first second -- node )
    [ 2array ] [ drop level>> 1+ ] 2bi node boa ;

: new-child ( new-child node -- node' expansion/f )
    dup full? [ tuck level>> 1node ] [ node-add f ] if ;

: new-last ( val seq -- seq' )
    [ length 1- ] keep new-nth ;

: node-set-last ( child node -- node' )
    clone [ new-last ] change-children ;

: (ppush-new-tail) ( tail node -- node' expansion/f )
    dup level>> 1 = [
        new-child
    ] [
        tuck children>> peek (ppush-new-tail)
        [ swap new-child ] [ swap node-set-last f ] ?if
    ] if ;

: do-expansion ( pvec root expansion/f -- pvec )
    [ 2node ] when* >>root ;

: ppush-new-tail ( val pvec -- pvec' )
    [ ] [ tail>> ] [ root>> ] tri
    (ppush-new-tail) do-expansion
    swap 0 1node >>tail ;

M: persistent-vector ppush ( val pvec -- pvec' )
    clone
    dup tail>> full?
    [ ppush-new-tail ] [ ppush-tail ] if
    [ 1+ ] change-count ;

: node-set-nth ( val i node -- node' )
    clone [ new-nth ] change-children ;

: node-change-nth ( i node quot -- node' )
    [ clone ] dip [
        [ clone ] dip [ change-nth ] 2keep drop
    ] curry change-children ; inline

: (new-nth) ( val i node -- node' )
    dup level>> 0 = [
        [ node-mask ] dip node-set-nth
    ] [
        [ dupd level>> node-shift node-mask ] keep
        [ (new-nth) ] node-change-nth
    ] if ;

M: persistent-vector new-nth ( obj i pvec -- pvec' )
    2dup count>> = [ nip ppush ] [
        clone
        2dup tail-offset >= [
            [ node-mask ] dip
            [ node-set-nth ] change-tail
        ] [
            [ (new-nth) ] change-root
        ] if
    ] if ;

: (ppop-contraction) ( node -- node' tail' )
    clone [ unclip-last swap ] change-children swap ;

: ppop-contraction ( node -- node' tail' )
    [ (ppop-contraction) ] [ level>> 1 = ] bi swap and ;

: (ppop-new-tail) ( root -- root' tail' )
    dup level>> 1 > [
        dup children>> peek (ppop-new-tail) over children>> empty?
        [ 2drop ppop-contraction ] [ [ swap node-set-last ] dip ] if
    ] [
        ppop-contraction
    ] if ;

: ppop-tail ( pvec -- pvec' )
    [ clone [ ppop ] change-children ] change-tail ;

: ppop-new-tail ( pvec -- pvec' )
    dup root>> (ppop-new-tail)
    [
        dup [ level>> 1 > ] [ children>> length 1 = ] bi and 
        [ children>> first ] when
    ] dip
    [ >>root ] [ >>tail ] bi* ;

PRIVATE>

: pempty ( -- pvec )
    T{ persistent-vector f 0 T{ node f { } 1 } T{ node f { } 0 } } ; inline

M: persistent-vector ppop ( pvec -- pvec' )
    dup count>> {
        { 0 [ empty-error ] }
        { 1 [ drop pempty ] }
        [
            [
                clone
                dup tail>> children>> length 1 >
                [ ppop-tail ] [ ppop-new-tail ] if
            ] dip 1- >>count
        ]
    } case ;

M: persistent-vector like
    drop pempty [ swap ppush ] reduce ;

M: persistent-vector equal?
    over persistent-vector? [ sequence= ] [ 2drop f ] if ;

: >persistent-vector ( seq -- pvec ) pempty like ; inline

: PV{ \ } [ >persistent-vector ] parse-literal ; parsing

M: persistent-vector pprint-delims drop \ PV{ \ } ;

M: persistent-vector >pprint-sequence ;

INSTANCE: persistent-vector immutable-sequence
