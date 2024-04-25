! Copyright (C) 2023 Keldan Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.smart continuations coroutines
effects.parser generalizations kernel locals.parser math
sequences summary vectors words ;
IN: generators

TUPLE: generator state ;

ERROR: stop-generator ;

ERROR: has-inputs ;

M: has-inputs summary
    drop "Generator quotation cannot require inputs" ;

: assert-no-inputs ( quot -- )
    inputs [ has-inputs ] unless-zero ;

: gen-coroutine ( quot gen -- co )
    '[ f _ state<< stop-generator ] compose cocreate ;

: <generator> ( quot -- gen )
    dup assert-no-inputs generator new
    [ gen-coroutine ] [ state<< ] [ ] tri ;

: next ( gen -- result )
    state>> [ *coresume ] [ stop-generator ] if* ;

: next* ( v gen -- result )
    state>> [ coresume ] [ drop stop-generator ] if* ;

ALIAS: yield  coyield*

ALIAS: yield* coyield

: make-gen-quot ( quot effect -- quot )
    in>> length '[ _ _ ncurry <generator> ] ;

SYNTAX: GEN: (:) [ make-gen-quot ] keep define-declared ;

SYNTAX: GEN:: (::) [ make-gen-quot ] keep define-declared ;

: skip ( gen -- ) next drop ; inline

: skip* ( v gen -- ) next* drop ; inline

: catch-stop-generator ( ..a try: ( ..a -- ..b ) except: ( ..a -- ..b ) -- ..b )
    [ dup stop-generator? [ drop ] [ rethrow ] if ] prepose recover ; inline

: ?next ( gen -- val/f end? )
    [ next f ] [ drop f t ] catch-stop-generator ;

: ?next* ( v gen -- val/f end? )
    [ next* f ] [ 2drop f t ] catch-stop-generator ;

:: take ( gen n -- seq )
    n <vector> :> accum
    [ n [ gen next accum push ] times ] [ ] catch-stop-generator
    accum { } like ;

:: take-all ( gen -- seq )
    V{ } clone :> accum
    [ [ gen next accum push t ] loop ] [ ] catch-stop-generator
    accum { } like ;

: yield-from ( gen -- )
    '[ [ _ next yield t ] loop ] [ ] catch-stop-generator ;

: exhausted? ( gen -- ? ) state>> not ;
