! Copyright (C) 2009 Slava Pestov, Eduardo Cavazos, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel locals.backend math
quotations sequences sets splitting vectors words ;
IN: fry

ERROR: not-in-a-fry ;

SYMBOL: in-fry?

ERROR: >r/r>-in-fry-error ;

GENERIC: fry ( object -- quot )

<PRIVATE

: check-fry ( quot -- quot )
    dup { load-local load-locals get-local drop-locals } intersect
    [ >r/r>-in-fry-error ] unless-empty ;

PREDICATE: fry-specifier < word { POSTPONE: _ POSTPONE: @ } member-eq? ;

GENERIC: count-inputs ( quot -- n )

M: sequence count-inputs [ count-inputs ] map-sum ;
M: fry-specifier count-inputs drop 1 ;
M: object count-inputs drop 0 ;

MIXIN: fried
PREDICATE: fried-sequence < sequence count-inputs 0 > ;
INSTANCE: fried-sequence fried

: (ncurry) ( accum n -- accum )
    {
        { 0 [ ] }
        { 1 [ \ curry  suffix! ] }
        { 2 [ \ 2curry suffix! ] }
        { 3 [ \ 3curry suffix! ] }
        [ [ \ 3curry suffix! ] dip 3 - (ncurry) ]
    } case ;

: wrap-non-callable ( obj -- quot )
    dup callable? [ ] [ [ call ] curry ] if ; inline

: [ncurry] ( n -- quot )
    [ V{ } clone ] dip (ncurry) >quotation ;

: [ndip] ( quot n -- quot' )
    {
        { 0 [ wrap-non-callable ] }
        { 1 [ \ dip  [ ] 2sequence ] }
        { 2 [ \ 2dip [ ] 2sequence ] }
        { 3 [ \ 3dip [ ] 2sequence ] }
        [ [ \ 3dip [ ] 2sequence ] dip 3 - [ndip] ]
    } case ;

: (make-curry) ( tail quot -- quot' )
    swap [ncurry] curry [ compose ] compose ;

: make-compose ( consecutive quot -- consecutive' quot' )
    [ [ [ ] ] [ [ncurry] ] if-zero ]
    [ [ [ compose ] ] [ [ compose compose ] curry ] if-empty ]
    bi* compose 0 swap ;

: make-curry ( consecutive quot -- consecutive' quot' )
    [ 1 + ] dip [ [ ] ] [ (make-curry) 0 swap ] if-empty ;

: convert-curry ( consecutive quot -- consecutive' quot' )
    [ [ ] make-curry ] [
        dup first \ @ =
        [ rest >quotation make-compose ]
        [ >quotation make-curry ] if
    ] if-empty ;

: prune-curries ( seq -- seq' )
    dup [ empty? not ] find
    [ [ 1 + tail ] dip but-last prefix ] [ 2drop { } ] if* ;

: convert-curries ( seq -- tail seq' )
    unclip-slice [ 0 swap [ convert-curry ] map ] dip
    [ prune-curries ] [ >quotation 1quotation prefix ] if-empty ;

: mark-composes ( quot -- quot' )
    [
        dup \ @ = [
            drop [ POSTPONE: _ POSTPONE: @ ]
        ] [
            1quotation
        ] if
    ] map concat ; inline

: shallow-fry ( quot -- quot' )
    check-fry mark-composes
    { POSTPONE: _ } split convert-curries
    [ [ [ ] ] [ [ ] (make-curry) but-last ] if-zero ]
    [ shallow-spread>quot swap [ [ ] (make-curry) compose ] unless-zero ] if-empty ;

TUPLE: dredge-fry-state
    { input sequence read-only }
    { prequot vector read-only }
    { quot vector read-only } ;

: <dredge-fry> ( quot -- dredge-fry )
    V{ } clone V{ } clone dredge-fry-state boa ; inline

: input-slices ( n i state -- head tail )
    input>> [ <slice> ] [ spin drop 1 + tail-slice ] 3bi ; inline

: push-head-slice ( head state -- )
    quot>> [ push-all ] [ \ _ swap push ] bi ; inline

: push-subquot ( tail elt state -- )
    [ fry swap count-inputs [ndip] ] dip prequot>> push-all ; inline

DEFER: dredge-fry

: dredge-fry-subquot ( n state i elt -- )
    rot {
        [ nip input-slices ] ! head tail i elt state
        [ [ 2drop swap ] dip push-head-slice ]
        [ nipd push-subquot ]
        [ [ drop 1 + ] dip dredge-fry ]
    } 3cleave ; inline recursive

: dredge-fry-simple ( n state -- )
    [ input>> swap tail-slice ] [ quot>> ] bi push-all ; inline recursive

: dredge-fry ( n dredge-fry -- )
    2dup input>> [ fried? ] find-from
    [ dredge-fry-subquot ]
    [ drop dredge-fry-simple ] if* ; inline recursive

: (fry) ( sequence -- quot )
    <dredge-fry>
    [ 0 swap dredge-fry ]
    [ prequot>> >quotation ]
    [ quot>> >quotation shallow-fry ] tri append ;

PRIVATE>

M: callable fry
    [ [ [ ] ] ] [ (fry) ] if-empty ;

M: sequence fry
    [ 0 swap new-sequence ] keep
    [ 1quotation ] [ (fry) swap [ like ] curry append ] if-empty ;
