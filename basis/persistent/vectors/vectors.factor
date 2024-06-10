! Based on Clojure's PersistentVector by Rich Hickey.

USING: math accessors kernel sequences.private sequences arrays
combinators combinators.short-circuit parser prettyprint.custom
persistent.sequences ;
IN: persistent.vectors

<PRIVATE

TUPLE: node { children array } { level fixnum } ;

PRIVATE>

ERROR: empty-error pvec ;

TUPLE: persistent-vector
{ count fixnum }
{ root node initial: T{ node f { } 1 } }
{ tail node initial: T{ node f { } 0 } } ;

M: persistent-vector length count>> ;

<PRIVATE

CONSTANT: node-size 32

: node-mask ( m -- n ) node-size mod ; inline

: node-shift ( m n -- x ) -5 * shift ; inline

: node-nth ( i node -- obj )
    [ node-mask ] [ children>> ] bi* nth ;

: body-nth ( i node -- i node' )
    dup level>> [
        dupd [ level>> node-shift ] keep node-nth
    ] times ;

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
    [ 1array ] dip node boa ;

: 2node ( first second -- node )
    [ 2array ] [ drop level>> 1 + ] 2bi node boa ;

: new-child ( new-child node -- node' expansion/f )
    dup full? [ [ level>> 1node ] guard ] [ node-add f ] if ;

: new-last ( val seq -- seq' )
    index-of-last new-nth ;

: node-set-last ( child node -- node' )
    clone [ new-last ] change-children ;

: (ppush-new-tail) ( tail node -- node' expansion/f )
    dup level>> 1 = [
        new-child
    ] [
        [ nip ] 2keep children>> last (ppush-new-tail)
        or? [ swap new-child ] [ swap node-set-last f ] if
    ] if ;

: do-expansion ( pvec root expansion/f -- pvec )
    [ 2node ] when* >>root ;

: ppush-new-tail ( val pvec -- pvec' )
    [ ] [ tail>> ] [ root>> ] tri
    (ppush-new-tail) do-expansion
    swap 0 1node >>tail ;

M: persistent-vector ppush
    clone
    dup tail>> full?
    [ ppush-new-tail ] [ ppush-tail ] if
    [ 1 + ] change-count ;

: node-set-nth ( val i node -- node' )
    clone [ new-nth ] change-children ;

: node-change-nth ( i node quot -- node' )
    [ clone ] dip [
        [ clone ] dip [ change-nth ] keepd
    ] curry change-children ; inline

: (new-nth) ( val i node -- node' )
    dup level>> 0 = [
        [ node-mask ] dip node-set-nth
    ] [
        [ dupd level>> node-shift node-mask ] keep
        [ (new-nth) ] node-change-nth
    ] if ;

M: persistent-vector new-nth
    2dup count>> = [ nip ppush ] [
        clone
        2dup tail-offset >= [
            [ node-mask ] dip
            [ node-set-nth ] change-tail
        ] [
            [ (new-nth) ] change-root
        ] if
    ] if ;

! The pop code is really convoluted. I don't understand Rich Hickey's
! original code. It uses a 'Box' out parameter which is passed around
! inside a recursive function, and gets mutated along the way to boot.
! Super-confusing.
: ppop-tail ( pvec -- pvec' )
    [ clone [ ppop ] change-children ] change-tail ;

: (ppop-contraction) ( node -- node' tail' )
    clone [ unclip-last swap ] change-children swap ;

: ppop-contraction ( node -- node' tail' )
    dup children>> length 1 =
    [ children>> last f swap ]
    [ (ppop-contraction) ]
    if ;

: (ppop-new-tail) ( root -- root' tail' )
    dup level>> 1 > [
        dup children>> last (ppop-new-tail) [
            dup
            [ swap node-set-last ]
            [ drop ppop-contraction drop ]
            if
        ] dip
    ] [
        ppop-contraction
    ] if ;

: trivial? ( node -- ? )
    { [ level>> 1 > ] [ children>> length 1 = ] } 1&& ;

: ppop-new-tail ( pvec -- pvec' )
    dup root>> (ppop-new-tail) [
        {
            { [ dup not ] [ drop T{ node f { } 1 } ] }
            { [ dup trivial? ] [ children>> first ] }
            [ ]
        } cond
    ] dip [ >>root ] [ >>tail ] bi* ;

PRIVATE>

M: persistent-vector ppop
    dup count>> {
        { 0 [ empty-error ] }
        { 1 [ drop T{ persistent-vector } ] }
        [
            [
                clone
                dup tail>> children>> length 1 >
                [ ppop-tail ] [ ppop-new-tail ] if
            ] dip 1 - >>count
        ]
    } case ;

M: persistent-vector like
    drop T{ persistent-vector } [ swap ppush ] reduce ;

M: persistent-vector equal?
    over persistent-vector? [ sequence= ] [ 2drop f ] if ;

: >persistent-vector ( seq -- pvec )
    T{ persistent-vector } like ;

SYNTAX: PV{ \ } [ >persistent-vector ] parse-literal ;

M: persistent-vector pprint-delims drop \ PV{ \ } ;
M: persistent-vector >pprint-sequence ;
M: persistent-vector pprint* pprint-object ;

INSTANCE: persistent-vector immutable-sequence
