! Copyright (C) 2009 Slava Pestov, Eduardo Cavazos, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel locals.backend math parser
quotations sequences sets splitting words ;
IN: fry

: _ ( -- * ) "Only valid inside a fry" throw ;
: @ ( -- * ) "Only valid inside a fry" throw ;

ERROR: >r/r>-in-fry-error ;

GENERIC: fry ( quot -- quot' )

<PRIVATE

: check-fry ( quot -- quot )
    dup { load-local load-locals get-local drop-locals } intersect
    [ >r/r>-in-fry-error ] unless-empty ;

PREDICATE: fry-specifier < word { _ @ } member-eq? ;

GENERIC: count-inputs ( quot -- n )

M: callable count-inputs [ count-inputs ] map-sum ;
M: fry-specifier count-inputs drop 1 ;
M: object count-inputs drop 0 ;

MIXIN: fried
PREDICATE: fried-callable < callable
    count-inputs 0 > ;
INSTANCE: fried-callable fried

: (ncurry) ( quot n -- quot )
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

: make-compose ( consecutive quot -- consecutive quot' )
    [
        [ [ ] ]
        [ [ncurry] ] if-zero
    ] [
        [ [ compose ] ]
        [ [ compose compose ] curry ] if-empty
    ] bi* compose
    0 swap ;

: make-curry ( consecutive quot -- consecutive' quot' )
    [ 1 + ] dip
    [ [ ] ] [ (make-curry) 0 swap ] if-empty ;

: convert-curry ( consecutive quot -- consecutive' quot' )
    [ [ ] make-curry ] [
        dup first \ @ =
        [ rest >quotation make-compose ]
        [ >quotation make-curry ] if
    ] if-empty ;

: prune-curries ( seq -- seq' )
    dup [ empty? not ] find
    [ [ 1 + tail ] dip but-last prefix ]
    [ 2drop { } ] if* ;

: convert-curries ( seq -- tail seq' )
    unclip-slice [ 0 swap [ convert-curry ] map ] dip
    [ prune-curries ]
    [ >quotation 1quotation prefix ] if-empty ;

: mark-composes ( quot -- quot' )
    [ dup \ @ = [ drop [ _ @ ] ] [ 1quotation ] if ] map concat ; inline

: shallow-fry ( quot -- quot' )
    check-fry mark-composes
    { _ } split convert-curries
    [ [ [ ] ] [ [ ] (make-curry) but-last ] if-zero ]
    [ shallow-spread>quot swap [ [ ] (make-curry) compose ] unless-zero ] if-empty ;

DEFER: dredge-fry

TUPLE: dredge-fry-state
    { in-quot read-only }
    { prequot read-only }
    { quot read-only } ;

: <dredge-fry> ( quot -- dredge-fry )
    V{ } clone V{ } clone dredge-fry-state boa ; inline

: in-quot-slices ( n i state -- head tail )
    in-quot>>
    [ <slice> ]
    [ nipd swap 1 + tail-slice ] 3bi ; inline

: push-head-slice ( head state -- )
    quot>> [ push-all ] [ \ _ swap push ] bi ; inline

: push-subquot ( tail elt state -- )
    [ fry swap >quotation count-inputs [ndip] ] dip prequot>> push-all ; inline

: (dredge-fry-subquot) ( n state i elt -- )
    rot {
        [ nip in-quot-slices ] ! head tail i elt state
        [ [ 2drop swap ] dip push-head-slice ]
        [ nipd push-subquot ]
        [ [ 1 + ] [ drop ] [ ] tri* dredge-fry ]
    } 3cleave ; inline recursive

: (dredge-fry-simple) ( n state -- )
    [ in-quot>> swap tail-slice ] [ quot>> ] bi push-all ; inline recursive

: dredge-fry ( n dredge-fry -- )
    2dup in-quot>> [ fried? ] find-from
    [ (dredge-fry-subquot) ]
    [ drop (dredge-fry-simple) ] if* ; inline recursive

PRIVATE>

M: callable fry ( quot -- quot' )
    [ [ [ ] ] ] [
        0 swap <dredge-fry>
        [ dredge-fry ] [
            [ prequot>> >quotation ]
            [ quot>> >quotation shallow-fry ] bi append
        ] bi
    ] if-empty ;

SYNTAX: '[ parse-quotation fry append! ;
