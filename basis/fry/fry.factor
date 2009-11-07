! (c)2009 Slava Pestov, Eduardo Cavazos, Joe Groff bsd license
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

: convert-curry ( quot -- quot' )
    [ [ [ ] curry compose ] ] [
        dup first \ @ =
        [ rest >quotation \ compose \ compose [ ] 3sequence ]
        [ >quotation \ curry \ compose [ ] 3sequence ] if
    ] if-empty ;

: convert-curries ( seq -- seq' )
    unclip-slice [ [ convert-curry ] map ] [ >quotation 1quotation ] bi* prefix ;

: shallow-fry ( quot -- quot' )
    check-fry
    [ dup \ @ = [ drop [ _ @ ] ] [ 1quotation ] if ] map concat
    { _ } split convert-curries
    spread>quot ;

: [ncurry] ( quot n -- quot )
    {
        { 0 [ [ ] ] }
        { 1 [ [ curry ] ] }
        { 2 [ [ 2curry ] ] }
        { 3 [ [ 3curry ] ] }
        [ \ curry <repetition> ]
    } case curry ;

: [ndip] ( quot n -- quot' )
    {
        { 0 [ \ call [ ] 2sequence ] }
        { 1 [ \ dip  [ ] 2sequence ] }
        { 2 [ \ 2dip [ ] 2sequence ] }
        { 3 [ \ 3dip [ ] 2sequence ] }
        [ [ \ dip [ ] 2sequence ] times ]
    } case ;

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
    [ [ drop ] 2dip swap 1 + tail-slice ] 3bi ; inline

: push-head-slice ( head state -- )
    quot>> [ push-all ] [ \ _ swap push ] bi ; inline

: push-subquot ( tail elt state -- )
    [ fry swap >quotation count-inputs [ndip] ] dip prequot>> push-all ; inline

: (dredge-fry-subquot) ( n state i elt -- )
    rot {
        [ nip in-quot-slices ] ! head tail i elt state
        [ [ 2drop swap ] dip push-head-slice ]
        [ [ drop ] 2dip push-subquot ]
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
    0 swap <dredge-fry>
    [ dredge-fry ] [
        [ prequot>> >quotation ]
        [ quot>> >quotation shallow-fry ] bi append
    ] bi ;

SYNTAX: '[ parse-quotation fry append! ;
