USING: kernel words inspector slots quotations sequences assocs
math arrays inference effects shuffle continuations debugger
tuples namespaces vectors bit-arrays byte-arrays strings sbufs
math.functions macros ;
IN: inverse

TUPLE: fail ;
: fail ( -- * ) \ fail construct-empty throw ;
M: fail summary drop "Unification failed" ;

: assure ( ? -- ) [ fail ] unless ;

: =/fail ( obj1 obj2 -- )
    = assure ;

! Inverse of a quotation

: define-inverse ( word quot -- ) "inverse" set-word-prop ;

: define-math-inverse ( word quot1 quot2 -- )
    2array "math-inverse" set-word-prop ;

: define-pop-inverse ( word n quot -- )
    >r dupd "pop-length" set-word-prop r>
    "pop-inverse" set-word-prop ;

TUPLE: no-inverse word ;
: no-inverse ( word -- * ) \ no-inverse construct-empty throw ;
M: no-inverse summary
    drop "The word cannot be used in pattern matching" ;

: next ( revquot -- revquot* first )
    dup empty?
    [ "Badly formed math inverse" throw ]
    [ unclip-slice ] if ;

: constant-word? ( word -- ? )
    stack-effect
    [ effect-out length 1 = ] keep
    effect-in length 0 = and ;

: assure-constant ( constant -- quot )
    dup word? [
        dup constant-word?
        [ "Badly formed math inverse" throw ] unless
    ] when 1quotation ;

: swap-inverse ( math-inverse revquot -- revquot* quot )
    next assure-constant rot second [ swap ] swap 3compose ;

: pull-inverse ( math-inverse revquot const -- revquot* quot )
    assure-constant rot first compose ;

: ?word-prop ( word/object name -- value/f )
    over word? [ word-prop ] [ 2drop f ] if ;

GENERIC: inverse ( revquot word -- revquot* quot )

DEFER: [undo]

M: word inverse
    dup "inverse" word-prop [ ]
    [ dup primitive? [ no-inverse ] [ word-def [undo] ] if ] ?if ;

: undo-literal ( object -- quot )
    [ =/fail ] curry ;

M: object inverse undo-literal ;
M: symbol inverse undo-literal ;

PREDICATE: word math-inverse "math-inverse" word-prop ;
M: math-inverse inverse
    "math-inverse" word-prop
    swap next dup \ swap =
    [ drop swap-inverse ] [ pull-inverse ] if ;

PREDICATE: word pop-inverse "pop-length" word-prop ;
M: pop-inverse inverse
    [ "pop-length" word-prop cut-slice swap ] keep
    "pop-inverse" word-prop compose call ;

: (undo) ( revquot -- )
    dup empty? [ drop ]
    [ unclip-slice inverse % (undo) ] if ;

: [undo] ( quot -- undo )
    reverse [ (undo) ] [ ] make ;

MACRO: undo ( quot -- ) [undo] ;

! Inverse of selected words

\ swap [ swap ] define-inverse
\ dup [ [ =/fail ] keep ] define-inverse
\ 2dup [ over =/fail over =/fail ] define-inverse
\ 3dup [ pick =/fail pick =/fail pick =/fail ] define-inverse
\ pick [ >r pick r> =/fail ] define-inverse
\ tuck [ swapd [ =/fail ] keep ] define-inverse

\ >r [ r> ] define-inverse
\ r> [ >r ] define-inverse

\ tuple>array [ >tuple ] define-inverse
\ >tuple [ tuple>array ] define-inverse
\ reverse [ reverse ] define-inverse

\ undo 1 [ [ call ] curry ] define-pop-inverse
\ map 1 [ [undo] [ over sequence? assure map ] curry ] define-pop-inverse

\ exp [ log ] define-inverse
\ log [ exp ] define-inverse
\ not [ not ] define-inverse
\ sq [ sqrt ] define-inverse
\ sqrt [ sq ] define-inverse

: assert-literal ( n -- n )
    dup [ word? ] keep symbol? not and
    [ "Literal missing in pattern matching" throw ] when ;
\ + [ - ] [ - ] define-math-inverse
\ - [ + ] [ - ] define-math-inverse
\ * [ / ] [ / ] define-math-inverse
\ / [ * ] [ / ] define-math-inverse
\ ^ [ recip ^ ] [ [ log ] 2apply / ] define-math-inverse

\ ? 2 [
    [ assert-literal ] 2apply
    [ swap >r over = r> swap [ 2drop f ] [ = [ t ] [ fail ] if ] if ]
    2curry
] define-pop-inverse

: _ f ;
\ _ [ drop ] define-inverse

: both ( object object -- object )
    dupd assert= ;
\ both [ dup ] define-inverse

: assure-length ( seq length -- seq )
    over length =/fail ;

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
} [ \ dup swap \ assure 3array >quotation define-inverse ] assoc-each

! These actually work on all seqs--should they?
\ 1array [ 1 assure-length first ] define-inverse
\ 2array [ 2 assure-length first2 ] define-inverse
\ 3array [ 3 assure-length first3 ] define-inverse
\ 4array [ 4 assure-length first4 ] define-inverse

\ first [ 1array ] define-inverse
\ first2 [ 2array ] define-inverse
\ first3 [ 3array ] define-inverse
\ first4 [ 4array ] define-inverse

! Constructor inverse
: deconstruct-pred ( class -- quot )
    "predicate" word-prop [ dupd call assure ] curry ;

: slot-readers ( class -- quot )
    "slots" word-prop 1 tail ! tail gets rid of delegate
    [ slot-spec-reader 1quotation [ keep ] curry ] map concat
    [ ] like [ drop ] compose ;

: ?wrapped ( object -- wrapped )
    dup wrapper? [ wrapped ] when ;

: boa-inverse ( class -- quot )
    [ deconstruct-pred ] keep slot-readers compose ;

\ construct-boa 1 [ ?wrapped boa-inverse ] define-pop-inverse

: empty-inverse ( class -- quot )
    deconstruct-pred
    [ tuple>array 1 tail [ ] contains? [ fail ] when ]
    compose ;

\ construct-empty 1 [ ?wrapped empty-inverse ] define-pop-inverse

: writer>reader ( word -- word' )
    [ "writing" word-prop "slots" word-prop ] keep
    [ swap slot-spec-writer = ] curry find nip slot-spec-reader ;

: construct-inverse ( class setters -- quot )
    >r deconstruct-pred r>
    [ writer>reader ] map [ get-slots ] curry
    compose ;

\ construct 2 [ >r ?wrapped r> construct-inverse ] define-pop-inverse

! More useful inverse-based combinators

: recover-fail ( try fail -- )
    [ drop call ] [
        >r nip r> dup fail?
        [ drop call ] [ nip throw ] if
    ] recover ; inline

: true-out ( quot effect -- quot' )
    effect-out [ ndrop ] curry
    [ t ] 3compose ;

: false-recover ( effect -- quot )
    effect-in [ ndrop f ] curry [ recover-fail ] curry ;

: [matches?] ( quot -- undoes?-quot )
    [undo] dup infer [ true-out ] keep false-recover curry ;

MACRO: matches? ( quot -- ? ) [matches?] ;

TUPLE: no-match ;
: no-match ( -- * ) \ no-match construct-empty throw ;
M: no-match summary drop "Fall through in switch" ;

: recover-chain ( seq -- quot )
    [ no-match ] [ swap \ recover-fail 3array >quotation ] reduce ;

: [switch]  ( quot-alist -- quot )
    reverse [ >r [undo] r> compose ] { } assoc>map
    recover-chain ;

MACRO: switch ( quot-alist -- ) [switch] ;
