! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces sequences sequences.private assocs math
inference.transforms parser words quotations debugger macros
arrays macros splitting combinators prettyprint.backend
definitions prettyprint hashtables combinators.lib
prettyprint.sections sequences.private effects generic
compiler.units combinators.cleave accessors ;
IN: locals

! Inspired by
! http://cat-language.googlecode.com/svn/trunk/CatPointFreeForm.cs

<PRIVATE

TUPLE: lambda vars body ;

C: <lambda> lambda

TUPLE: let bindings body ;

C: <let> let

TUPLE: let* bindings body ;

C: <let*> let*

TUPLE: wlet bindings body ;

C: <wlet> wlet

PREDICATE: local < word "local?" word-prop ;

: <local> ( name -- word )
    #! Create a local variable identifier
    f <word> dup t "local?" set-word-prop ;

PREDICATE: local-word < word "local-word?" word-prop ;

: <local-word> ( name -- word )
    f <word> dup t "local-word?" set-word-prop ;

PREDICATE: local-reader < word "local-reader?" word-prop ;

: <local-reader> ( name -- word )
    f <word> dup t "local-reader?" set-word-prop ;

PREDICATE: local-writer < word "local-writer?" word-prop ;

: <local-writer> ( reader -- word )
    dup word-name "!" append f <word>
    [ t "local-writer?" set-word-prop ] keep
    [ "local-writer" set-word-prop ] 2keep
    [ swap "local-reader" set-word-prop ] keep ;

TUPLE: quote local ;

C: <quote> quote

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! read-local
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: local-index ( obj args -- n )
    [ dup quote? [ quote-local ] when eq? ] with find drop ;

: read-local ( obj args -- quot )
    local-index 1+
    dup [ r> ] <repetition> concat [ dup ] append
    swap [ swap >r ] <repetition> concat append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! localize
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: localize-writer ( obj args -- quot )
  >r "local-reader" word-prop r> read-local [ 0 swap set-array-nth ] append ;

: localize ( obj args -- quot )
    {
        { [ over local? ]        [ read-local ] }
        { [ over quote? ]        [ >r quote-local r> read-local ] }
        { [ over local-word? ]   [ read-local [ call ] append ] }
        { [ over local-reader? ] [ read-local [ 0 swap array-nth ] append ] }
        { [ over local-writer? ] [ localize-writer ] }
        { [ over \ lambda eq? ]  [ 2drop [ ] ] }
        { [ t ]                  [ drop 1quotation ] }
    } cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! point-free
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

UNION: special local quote local-word local-reader local-writer ;

: load-local ( arg -- quot ) 
    local-reader? [ 1array >r ] [ >r ] ? ;

: load-locals ( quot args -- quot )
    nip <reversed> [ load-local ] map concat ;

: drop-locals ( args -- args quot )
    dup length [ r> drop ] <repetition> concat ;

: point-free-body ( quot args -- newquot )
    >r 1 head-slice* r> [ localize ] curry map concat ;

: point-free-end ( quot args -- newquot )
    over peek special?
    [ drop-locals >r >r peek r> localize r> append ]
    [ drop-locals nip swap peek add ]
    if ;

: (point-free) ( quot args -- newquot )
    [ load-locals ] [ point-free-body ] [ point-free-end ]
    2tri 3append >quotation ;

: point-free ( quot args -- newquot )
    over empty? [ drop ] [ (point-free) ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! free-vars
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

UNION: lexical local local-reader local-writer local-word ;

GENERIC: free-vars ( form -- vars )

: add-if-free ( vars object -- vars )
  {
      { [ dup local-writer? ] [ "local-reader" word-prop add ] }
      { [ dup lexical? ]      [ add ] }
      { [ dup quote? ]        [ quote-local add ] }
      { [ t ]                 [ free-vars append ] }
  } cond ;

M: object free-vars drop { } ;

M: quotation free-vars { } [ add-if-free ] reduce ;

M: lambda free-vars
    dup vars>> swap body>> free-vars seq-diff ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! lambda-rewrite
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: lambda-rewrite* ( obj -- )

GENERIC: local-rewrite* ( obj -- )

: lambda-rewrite
    [ local-rewrite* ] [ ] make
    [ [ lambda-rewrite* ] each ] [ ] make ;

UNION: block callable lambda ;

GENERIC: block-vars ( block -- seq )

GENERIC: block-body ( block -- quot )

M: callable block-vars drop { } ;

M: callable block-body ;

M: callable local-rewrite*
    [ [ local-rewrite* ] each ] [ ] make , ;

M: lambda block-vars vars>> ;

M: lambda block-body body>> ;

M: lambda local-rewrite*
    dup vars>> swap body>>
    [ local-rewrite* \ call , ] [ ] make <lambda> , ;

M: block lambda-rewrite*
    #! Turn free variables into bound variables, curry them
    #! onto the body
    dup free-vars [ <quote> ] map dup % [
        over block-vars prepend
        swap block-body [ [ lambda-rewrite* ] each ] [ ] make
        swap point-free ,
    ] keep length \ curry <repetition> % ;

M: object lambda-rewrite* , ;

M: object local-rewrite* , ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-local ( name -- word )
    "!" ?tail [
        <local-reader>
        dup <local-writer> dup word-name set
    ] [ <local> ] if
    dup dup word-name set ;

: make-locals ( seq -- words assoc )
    [ [ make-local ] map ] H{ } make-assoc ;

: make-local-word ( name -- word )
    <local-word> dup dup word-name set ;

: push-locals ( assoc -- )
    use get push ;

: pop-locals ( assoc -- )
    use get delete ;

: (parse-lambda) ( assoc end -- quot )
    parse-until >quotation swap pop-locals ;

: parse-lambda ( -- lambda )
    "|" parse-tokens make-locals dup push-locals
    \ ] (parse-lambda) <lambda> ;

: parse-binding ( -- pair/f )
    scan dup "|" = [
        drop f
    ] [
        scan {
            { "[" [ \ ] parse-until >quotation ] }
            { "[|" [ parse-lambda ] }
        } case 2array
    ] if ;

: (parse-bindings) ( -- )
    parse-binding [
        first2 >r make-local r> 2array ,
        (parse-bindings)
    ] when* ;

: parse-bindings ( -- bindings vars )
    [
        [ (parse-bindings) ] H{ } make-assoc
        dup push-locals
    ] { } make swap ;

: parse-bindings* ( -- words assoc )
    [
        [
            namespace push-locals

            (parse-bindings)
        ] { } make-assoc
    ] { } make swap ;

: (parse-wbindings) ( -- )
    parse-binding [
        first2 >r make-local-word r> 2array ,
        (parse-wbindings)
    ] when* ;

: parse-wbindings ( -- bindings vars )
    [
        [ (parse-wbindings) ] H{ } make-assoc
        dup push-locals
    ] { } make swap ;

: let-rewrite ( body bindings -- )
    <reversed> [
        >r 1array r> spin <lambda> [ call ] curry compose
    ] assoc-each local-rewrite* \ call , ;

M: let local-rewrite*
    { body>> bindings>> } get-slots let-rewrite ;

M: let* local-rewrite*
    { body>> bindings>> } get-slots let-rewrite ;

M: wlet local-rewrite*
    { body>> bindings>> } get-slots
    [ [ ] curry ] assoc-map
    let-rewrite ;

: parse-locals ( -- vars assoc )
    parse-effect
    word [ over "declared-effect" set-word-prop ] when*
    effect-in make-locals dup push-locals ;

: parse-locals-definition ( word -- word quot )
    scan "(" assert= parse-locals \ ; (parse-lambda) <lambda>
    2dup "lambda" set-word-prop
    lambda-rewrite first ;

: (::) CREATE-WORD parse-locals-definition ;

: (M::) CREATE-METHOD parse-locals-definition ;

PRIVATE>

: [| parse-lambda parsed ; parsing

: [let
    scan "|" assert= parse-bindings
\ ] (parse-lambda) <let> parsed ; parsing

: [let*
    scan "|" assert= parse-bindings*
    >r \ ] parse-until >quotation <let*> parsed r> pop-locals ;
    parsing

: [wlet
    scan "|" assert= parse-wbindings
    \ ] (parse-lambda) <wlet> parsed ; parsing

MACRO: with-locals ( form -- quot ) lambda-rewrite ;

: :: (::) define ; parsing

: M:: (M::) define ; parsing

: MACRO:: (::) define-macro ; parsing

<PRIVATE

! Pretty-printing locals
SYMBOL: |

: pprint-var ( var -- )
    #! Prettyprint a read/write local as its writer, just like
    #! in the input syntax: [| x! | ... x 3 + x! ]
    dup local-reader? [
        "local-writer" word-prop
    ] when pprint-word ;

: pprint-vars ( vars -- ) [ pprint-var ] each ;

M: lambda pprint*
    <flow
    \ [| pprint-word
    dup vars>> pprint-vars
    \ | pprint-word
    f <inset body>> pprint-elements block>
    \ ] pprint-word
    block> ;

: pprint-let ( let word -- )
    pprint-word
    { body>> bindings>> } get-slots
    \ | pprint-word
    t <inset
    <block
    [ <block >r pprint-var r> pprint* block> ] assoc-each
    block>
    \ | pprint-word
    <block pprint-elements block>
    block>
    \ ] pprint-word ;

M: let pprint* \ [let pprint-let ;

M: wlet pprint* \ [wlet pprint-let ;

M: let* pprint* \ [let* pprint-let ;

PREDICATE: lambda-word < word
    "lambda" word-prop >boolean ;

M: lambda-word definer drop \ :: \ ; ;

M: lambda-word definition
    "lambda" word-prop body>> ;

: lambda-word-synopsis ( word -- )
    dup definer.
    dup seeing-word
    dup pprint-word
    stack-effect. ;

M: lambda-word synopsis* lambda-word-synopsis ;

PREDICATE: lambda-macro < macro
    "lambda" word-prop >boolean ;

M: lambda-macro definer drop \ MACRO:: \ ; ;

M: lambda-macro definition
    "lambda" word-prop body>> ;

M: lambda-macro synopsis* lambda-word-synopsis ;

PREDICATE: lambda-method < method-body
    "lambda" word-prop >boolean ;

M: lambda-method definer drop \ M:: \ ; ;

M: lambda-method definition
    "lambda" word-prop body>> ;

: method-stack-effect ( method -- effect )
    dup "lambda" word-prop vars>>
    swap "method-generic" word-prop stack-effect
    dup [ effect-out ] when
    <effect> ;

M: lambda-method synopsis*
    dup dup dup definer.
    "method-specializer" word-prop pprint*
    "method-generic" word-prop pprint*
    method-stack-effect effect>string comment. ;

PRIVATE>
