! Copyright (C) 2007, 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel words summary slots quotations
sequences assocs math arrays stack-checker effects generalizations
continuations debugger classes.tuple namespaces make vectors
bit-arrays byte-arrays strings sbufs math.functions macros
sequences.private combinators mirrors splitting combinators.smart
combinators.short-circuit fry words.symbol generalizations
classes ;
IN: inverse

ERROR: fail ;
M: fail summary drop "Matching failed" ;

: assure ( ? -- ) [ fail ] unless ; inline

: =/fail ( obj1 obj2 -- ) = assure ; inline

! Inverse of a quotation

: define-inverse ( word quot -- ) "inverse" set-word-prop ;

: define-dual ( word1 word2 -- )
    2dup swap [ 1quotation define-inverse ] 2bi@ ;

: define-involution ( word -- ) dup 1quotation define-inverse ;

: define-math-inverse ( word quot1 quot2 -- )
    pick 1quotation 3array "math-inverse" set-word-prop ;

: define-pop-inverse ( word n quot -- )
    [ dupd "pop-length" set-word-prop ] dip
    "pop-inverse" set-word-prop ;

ERROR: no-inverse word ;
M: no-inverse summary
    drop "The word cannot be used in pattern matching" ;

ERROR: bad-math-inverse ;

: next ( revquot -- revquot* first )
    [ bad-math-inverse ]
    [ unclip-slice ] if-empty ;

: constant-word? ( word -- ? )
    stack-effect
    [ out>> length 1 = ]
    [ in>> empty? ] bi and ;

: assure-constant ( constant -- quot )
    dup word? [ bad-math-inverse ] when 1quotation ;

: swap-inverse ( math-inverse revquot -- revquot* quot )
    next assure-constant rot second '[ @ swap @ ] ;

: pull-inverse ( math-inverse revquot const -- revquot* quot )
    assure-constant rot first compose ;

: ?word-prop ( word/object name -- value/f )
    over word? [ word-prop ] [ 2drop f ] if ;

: undo-literal ( object -- quot ) [ =/fail ] curry ;

PREDICATE: normal-inverse < word "inverse" word-prop ;
PREDICATE: math-inverse < word "math-inverse" word-prop ;
PREDICATE: pop-inverse < word "pop-length" word-prop ;
UNION: explicit-inverse normal-inverse math-inverse pop-inverse ;

: enough? ( stack word -- ? )
    dup deferred? [ 2drop f ] [
        [ [ length ] [ 1quotation infer in>> ] bi* >= ]
        [ 3drop f ] recover
    ] if ;

: fold-word ( stack word -- stack )
    2dup enough?
    [ 1quotation with-datastack ]
    [ [ [ literalize , ] each ] [ , ] bi* { } ]
    if ;

: fold ( quot -- folded-quot )
    [ { } [ fold-word ] reduce % ] [ ] make ; 

ERROR: no-recursive-inverse ;

SYMBOL: visited

: flattenable? ( object -- ? )
    { [ word? ] [ primitive? not ] [
        { "inverse" "math-inverse" "pop-inverse" }
        [ word-prop ] with any? not
    ] } 1&& ; 

: flatten ( quot -- expanded )
    [
        visited [ over suffix ] change
        [
            dup flattenable? [
                def>>
                [ visited get memq? [ no-recursive-inverse ] when ]
                [ flatten ]
                bi
            ] [ 1quotation ] if
        ] map concat
    ] with-scope ;

ERROR: undefined-inverse ;

GENERIC: inverse ( revquot word -- revquot* quot )

M: object inverse undo-literal ;

M: symbol inverse undo-literal ;

M: word inverse undefined-inverse ;

M: normal-inverse inverse
    "inverse" word-prop ;

M: math-inverse inverse
    "math-inverse" word-prop
    swap next dup \ swap =
    [ drop swap-inverse ] [ pull-inverse ] if ;

M: pop-inverse inverse
    [ "pop-length" word-prop cut-slice swap >quotation ]
    [ "pop-inverse" word-prop ] bi compose call( -- quot ) ;

: (undo) ( revquot -- )
    [ unclip-slice inverse % (undo) ] unless-empty ;

: [undo] ( quot -- undo )
    flatten fold reverse [ (undo) ] [ ] make ;

MACRO: undo ( quot -- ) [undo] ;

! Inverse of selected words

\ swap define-involution
\ dup [ [ =/fail ] keep ] define-inverse
\ 2dup [ over =/fail over =/fail ] define-inverse
\ 3dup [ pick =/fail pick =/fail pick =/fail ] define-inverse
\ pick [ [ pick ] dip =/fail ] define-inverse
\ tuck [ swapd [ =/fail ] keep ] define-inverse

\ bi@ 1 [ [undo] '[ _ bi@ ] ] define-pop-inverse
\ tri@ 1 [ [undo] '[ _ tri@ ] ] define-pop-inverse
\ bi* 2 [ [ [undo] ] bi@ '[ _ _ bi* ] ] define-pop-inverse
\ tri* 3 [ [ [undo] ] tri@ '[ _ _ _ tri* ] ] define-pop-inverse

\ not define-involution
\ >boolean [ dup { t f } memq? assure ] define-inverse

\ tuple>array \ >tuple define-dual
\ reverse define-involution

\ undo 1 [ ] define-pop-inverse
\ map 1 [ [undo] '[ dup sequence? assure _ map ] ] define-pop-inverse

\ exp \ log define-dual
\ sq \ sqrt define-dual

ERROR: missing-literal ;

: assert-literal ( n -- n )
    dup
    [ word? ] [ symbol? not ] bi and
    [ missing-literal ] when ;
\ + [ - ] [ - ] define-math-inverse
\ - [ + ] [ - ] define-math-inverse
\ * [ / ] [ / ] define-math-inverse
\ / [ * ] [ / ] define-math-inverse
\ ^ [ recip ^ ] [ swap [ log ] bi@ / ] define-math-inverse

\ ? 2 [
    [ assert-literal ] bi@
    [ swap [ over = ] dip swap [ 2drop f ] [ = [ t ] [ fail ] if ] if ]
    2curry
] define-pop-inverse

DEFER: __
\ __ [ drop ] define-inverse

: both ( object object -- object )
    dupd assert= ;
\ both [ dup ] define-inverse

{
    { >array array? }
    { >vector vector? }
    { >fixnum fixnum? }
    { >bignum bignum? }
    { >bit-array bit-array? }
    { >float float? }
    { >byte-array byte-array? }
    { >string string? }
    { >sbuf sbuf? }
    { >quotation quotation? }
} [ '[ dup _ execute assure ] define-inverse ] assoc-each

: assure-length ( seq length -- )
    swap length =/fail ; inline

: assure-array ( array -- array )
    dup array? assure ; inline

: undo-narray ( array n -- ... )
    [ assure-array ] dip
    [ assure-length ] [ firstn ] 2bi ; inline

\ 1array [ 1 undo-narray ] define-inverse
\ 2array [ 2 undo-narray ] define-inverse
\ 3array [ 3 undo-narray ] define-inverse
\ 4array [ 4 undo-narray ] define-inverse
\ narray 1 [ '[ _ undo-narray ] ] define-pop-inverse

\ first [ 1array ] define-inverse
\ first2 [ 2array ] define-inverse
\ first3 [ 3array ] define-inverse
\ first4 [ 4array ] define-inverse

\ prefix \ unclip define-dual
\ suffix [ dup but-last swap peek ] define-inverse

\ append 1 [ [ ?tail assure ] curry ] define-pop-inverse
\ prepend 1 [ [ ?head assure ] curry ] define-pop-inverse

: assure-same-class ( obj1 obj2 -- )
    [ class ] bi@ = assure ; inline

\ output>sequence 2 [ [undo] '[ dup _ assure-same-class _ input<sequence ] ] define-pop-inverse
\ input<sequence 1 [ [undo] '[ _ { } output>sequence ] ] define-pop-inverse

! Constructor inverse
: deconstruct-pred ( class -- quot )
    "predicate" word-prop [ dupd call assure ] curry ;

: slot-readers ( class -- quot )
    all-slots [ name>> reader-word 1quotation ] map [ cleave ] curry ;

: ?wrapped ( object -- wrapped )
    dup wrapper? [ wrapped>> ] when ;

: boa-inverse ( class -- quot )
    [ deconstruct-pred ] [ slot-readers ] bi compose ;

\ boa 1 [ ?wrapped boa-inverse ] define-pop-inverse

: empty-inverse ( class -- quot )
    deconstruct-pred
    [ tuple>array rest [ ] any? [ fail ] when ]
    compose ;

\ new 1 [ ?wrapped empty-inverse ] define-pop-inverse

! More useful inverse-based combinators

: recover-fail ( try fail -- )
    [ drop call ] [
        [ nip ] dip dup fail?
        [ drop call ] [ nip throw ] if
    ] recover ; inline

: true-out ( quot effect -- quot' )
    out>> '[ @ _ ndrop t ] ;

: false-recover ( effect -- quot )
    in>> [ ndrop f ] curry [ recover-fail ] curry ;

: [matches?] ( quot -- undoes?-quot )
    [undo] dup infer [ true-out ] [ false-recover ] bi curry ;

MACRO: matches? ( quot -- ? ) [matches?] ;

ERROR: no-match ;
M: no-match summary drop "Fall through in switch" ;

: recover-chain ( seq -- quot )
    [ no-match ] [ swap \ recover-fail 3array >quotation ] reduce ;

: [switch]  ( quot-alist -- quot )
    [ dup quotation? [ [ ] swap 2array ] when ] map
    reverse [ [ [undo] ] dip compose ] { } assoc>map
    recover-chain ;

MACRO: switch ( quot-alist -- ) [switch] ;
