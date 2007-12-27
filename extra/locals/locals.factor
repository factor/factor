! Inspired by
! http://cat-language.googlecode.com/svn/trunk/CatPointFreeForm.cs

USING: kernel namespaces sequences sequences.private assocs
       math inference.transforms parser words quotations debugger
       macros arrays macros splitting combinators prettyprint.backend
       definitions prettyprint hashtables combinators.lib
       prettyprint.sections ;

IN: locals

<PRIVATE

TUPLE: lambda vars body ;

C: <lambda> lambda

TUPLE: let bindings vars body ;

C: <let> let

TUPLE: wlet bindings vars body ;

C: <wlet> wlet

PREDICATE: word local "local?" word-prop ;

: <local> ( name -- word )
    #! Create a local variable identifier
    f <word> dup t "local?" set-word-prop ;

PREDICATE: word local-word "local-word?" word-prop ;

: <local-word> ( name -- word )
    f <word> dup t "local-word?" set-word-prop ;

PREDICATE: word local-reader "local-reader?" word-prop ;

: <local-reader> ( name -- word )
    f <word> dup t "local-reader?" set-word-prop ;

PREDICATE: word local-writer "local-writer?" word-prop ;

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
    [ dup quote? [ quote-local ] when eq? ] curry* find drop ;

: read-local ( obj args -- quot )
    local-index 1+
    dup [ r> ] <repetition> concat [ dup ] append
    swap [ swap >r ] <repetition> concat append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! localize
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: localize-writer ( obj args -- quot )
  >r "local-reader" word-prop r> read-local [ set-first ] append ;

: localize ( obj args -- quot )
    {
        { [ over local? ]        [ read-local ] }
        { [ over quote? ]        [ >r quote-local r> read-local ] }
        { [ over local-word? ]   [ read-local [ call ] append ] }
        { [ over local-reader? ] [ read-local [ first ] append ] }
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
    { [ load-locals ] [ point-free-body ] [ point-free-end ] }
    map-call-with2 concat >quotation ;

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
    dup lambda-vars swap lambda-body free-vars seq-diff ;

M: let free-vars
    dup let-vars swap let-body free-vars seq-diff ;

M: wlet free-vars
    dup wlet-vars swap wlet-body free-vars seq-diff ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! lambda-rewrite
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: lambda-rewrite* ( obj -- )

: lambda-rewrite [ lambda-rewrite* ] [ ] make ;

UNION: block quotation lambda ;

GENERIC: block-vars ( block -- seq )

GENERIC: block-body ( block -- quot )

M: quotation block-vars drop { } ;

M: quotation block-body ;

M: lambda block-vars lambda-vars ;

M: lambda block-body lambda-body ;

M: block lambda-rewrite*
    #! Turn free variables into bound variables, curry them
    #! onto the body
    dup free-vars [ <quote> ] map dup % [
        over block-vars swap append
        swap block-body [ [ lambda-rewrite* ] each ] [ ] make
        swap point-free ,
    ] keep length \ curry <repetition> % ;

M: object lambda-rewrite* , ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-locals ( seq -- words assoc )
    [
        "!" ?tail [ <local-reader> ] [ <local> ] if
    ] map dup [
        dup
        [ dup word-name set ] each
        [
            dup local-reader? [
                <local-writer> dup word-name set
            ] [
                drop
            ] if
        ] each
    ] H{ } make-assoc ;

: make-local-words ( seq -- words assoc )
    [ dup <local-word> ] { } map>assoc
    dup values swap ;

: push-locals ( assoc -- )
    use get push ;

: parse-locals ( -- words assoc )
    "|" parse-tokens make-locals ;

: pop-locals ( assoc -- )
    use get delete ;

: (parse-lambda) ( assoc end -- quot )
    over push-locals parse-until >quotation swap pop-locals ;

: parse-lambda ( -- lambda )
    parse-locals \ ] (parse-lambda) <lambda> ;

: (parse-bindings) ( -- )
    scan dup "|" = [
        drop
    ] [
        scan {
            { "[" [ \ ] parse-until >quotation ] }
            { "[|" [ parse-lambda ] }
        } case 2array ,
        (parse-bindings)
    ] if ;

: parse-bindings ( -- alist )
    scan "|" assert= [ (parse-bindings) ] { } make dup keys ;

: let-rewrite ( words body -- )
    <lambda> lambda-rewrite* \ call , ;

M: let lambda-rewrite*
    dup let-bindings values [ lambda-rewrite* \ call , ] each
    { let-vars let-body } get-slots let-rewrite ;

M: wlet lambda-rewrite*
    dup wlet-bindings values [ lambda-rewrite* ] each
    { wlet-vars wlet-body } get-slots let-rewrite ;

: (::) ( prop -- word quot n )
    >r CREATE dup reset-generic
    scan "|" assert= parse-locals \ ; (parse-lambda) <lambda>
    2dup r> set-word-prop
    [ lambda-rewrite first ] keep lambda-vars length ;

PRIVATE>

: [| parse-lambda parsed ; parsing

: [let
    parse-bindings
    make-locals \ ] (parse-lambda)
    <let> parsed ; parsing

: [wlet
    parse-bindings
    make-local-words \ ] (parse-lambda)
    <wlet> parsed ; parsing

MACRO: with-locals ( form -- quot ) lambda-rewrite ;

: :: "lambda" (::) drop define-compound ; parsing

: MACRO:: "lambda-macro" (::) (MACRO:) ; parsing

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
    dup lambda-vars pprint-vars
    \ | pprint-word
    f <inset lambda-body pprint-elements block>
    \ ] pprint-word
    block> ;

: pprint-let ( body vars bindings -- )
    \ | pprint-word
    t <inset
    <block
    values [ <block >r pprint-word r> pprint* block> ] 2each
    block>
    \ | pprint-word
    <block pprint-elements block>
    block> ;

M: let pprint*
    \ [let pprint-word
    { let-body let-vars let-bindings } get-slots pprint-let
    \ ] pprint-word ;

M: wlet pprint*
    \ [let pprint-word
    { wlet-body wlet-vars wlet-bindings } get-slots pprint-let
    \ ] pprint-word ;

PREDICATE: compound lambda-word
    "lambda" word-prop >boolean ;

M: lambda-word definer drop \ :: \ ; ;

M: lambda-word definition
    "lambda" word-prop lambda-body ;

: lambda-word-synopsis ( word prop definer -- )
    pick seeing-word pprint-word over pprint-word
    \ | pprint-word
    word-prop lambda-vars pprint-vars
    \ | pprint-word ;

M: lambda-word synopsis*
    "lambda" \ :: lambda-word-synopsis ;

PREDICATE: macro lambda-macro
    "lambda-macro" word-prop >boolean ;

M: lambda-macro definer drop \ MACRO:: \ ; ;

M: lambda-macro definition
    "lambda-macro" word-prop lambda-body ;

M: lambda-macro synopsis*
    "lambda-macro" \ MACRO:: lambda-word-synopsis ;

PRIVATE>
