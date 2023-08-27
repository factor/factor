! Copyright (C) 2023 Keldan Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel coroutines effects.parser words sequences accessors generalizations
locals.parser summary combinators.smart math continuations make ;
IN: generators

TUPLE: generator state ;
ERROR: stop-generator ;
ERROR: has-inputs ;
M: has-inputs summary drop "Generator quotation cannot require inputs" ;

: assert-no-inputs ( quot -- ) inputs [ has-inputs ] unless-zero ;
: gen-coroutine ( quot gen -- co ) '[ f _ state<< stop-generator ] compose cocreate ;
: <generator> ( quot -- gen ) dup assert-no-inputs generator new [ gen-coroutine ] [ state<< ] [ ] tri ;

: next ( gen -- result ) state>> [ *coresume ] [ stop-generator ] if* ;
: next* ( v gen -- result ) state>> [ coresume ] [ drop stop-generator ] if* ;
ALIAS: yield  coyield*
ALIAS: yield* coyield

: make-gen-quot ( quot effect -- quot ) in>> length [ ncurry <generator> ] 2curry ;

SYNTAX: GEN: (:) [ make-gen-quot ] keep define-declared ;
SYNTAX: GEN:: (::) [ make-gen-quot ] keep define-declared ;

! Utilities
: skip ( gen -- ) next drop ; inline
: skip* ( v gen -- ) next* drop ; inline

: catch-stop-generator ( ..a try: ( ..a -- ..b ) except: ( ..a -- ..b ) -- ..b )
    [ stop-generator? [ rethrow ] unless ] prepose recover ; inline
: ?next ( gen -- val/f end? ) [ next f ] [ drop f t ] catch-stop-generator ;
: ?next* ( v gen -- val/f end? ) [ next* f ] [ 2drop f t ] catch-stop-generator ;
: take ( gen n -- seq ) [ swap '[ drop _ ?next [ , t ] unless ] all-integers? drop ] { } make ;
: take-all ( gen -- seq ) '[ _ ?next not ] [ ] produce nip ;

: yield-from ( gen -- ) '[ _ ?next [ drop f ] [ yield t ] if ] loop ;

: exhausted? ( gen -- ? ) state>> not ;
