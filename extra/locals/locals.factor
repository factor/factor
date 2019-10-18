! Inspired by
! http://cat-language.googlecode.com/svn/trunk/CatPointFreeForm.cs
USING: kernel namespaces sequences sequences.private assocs
math inference.transforms parser words quotations debugger
macros arrays macros splitting combinators ;
IN: locals

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
    dup t "local-writer?" set-word-prop
    tuck swap "local-reader" set-word-prop ;

TUPLE: quote local ;

C: <quote> quote

GENERIC: load-local ( local -- )

M: local-reader load-local
    drop [ 1array >r ] % ;

M: object load-local
    drop \ >r , ;

: load-locals, ( locals -- )
    [ load-local ] each ;

GENERIC# localize 1 ( obj args -- )

: local-index ( obj args -- n )
    [ dup quote? [ quote-local ] when eq? ]
    curry* find drop ;

: read-local ( obj args -- )
    local-index 1+
    dup \ r> <repetition> %
    \ dup ,
    [ swap >r ] <repetition> concat % ;

UNION: special
local quote local-word local-reader local-writer ;

M: local localize
    read-local ;

M: quote localize
    >r quote-local r> read-local ;

M: local-word localize
    read-local \ call , ;

M: local-reader localize
    read-local \ first , ;

M: local-writer localize
    >r "local-reader" word-prop r>
    read-local \ set-first , ;

M: object localize drop , ;

DEFER: lambda

M: word localize drop dup \ lambda eq? [ drop ] [ , ] if ;

: drop-locals, ( locals -- )
    #! Drop locals from retain stack
    length [ r> drop ] <repetition> concat % ;

: (point-free) ( quot args -- )
    #! Convert local variable references to stack shuffling
    [ localize ] curry each ;

: point-free ( quot args -- newquot )
    over empty? [
        2drop [ ]
    ] [
        [
            ! Tail call optimization
            dup load-locals,
            over 1 head-slice* over (point-free)
            over peek special? [
                over peek over localize
                drop-locals,
                drop
            ] [
                drop-locals,
                peek ,
            ] if
        ] [ ] make
    ] if ;

! Common protocol for quotations and lambdas; quotations have
! no inputs
GENERIC: block-vars ( block -- seq )

GENERIC: block-body ( block -- quot )

M: quotation block-vars drop { } ;

M: quotation block-body ;

TUPLE: lambda vars body ;

C: <lambda> lambda

M: lambda block-vars lambda-vars ;

M: lambda block-body lambda-body ;

UNION: block quotation lambda ;

GENERIC: free-vars* ( form -- )

: free-vars ( form -- seq ) [ free-vars* ] { } make ;

M: local free-vars* , ;

M: local-word free-vars* , ;

M: local-reader free-vars* , ;

M: quote free-vars* quote-local free-vars* ;

M: lambda free-vars*
    #! Any variables referenced by the body and not bound by
    #! the lambda form are free.
    dup lambda-vars swap lambda-body free-vars seq-diff % ;

M: quotation free-vars* [ free-vars* ] each ;

M: object free-vars* drop ;

GENERIC: lambda-rewrite* ( obj -- )

: (lambda-rewrite) ( seq -- seq' )
    [ [ lambda-rewrite* ] each ] [ ] make ;

M: block lambda-rewrite*
    #! Turn free variables into bound variables, curry them
    #! onto the body
    dup free-vars [ <quote> ] map dup % [
        over block-vars swap append
        swap block-body [ [ lambda-rewrite* ] each ] [ ] make
        swap point-free ,
    ] keep length \ curry <repetition> % ;

M: object lambda-rewrite* , ;

MACRO: lambda ( quot -- quot )
    [ lambda-rewrite* ] [ ] make ;

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

: pop-locals ( -- )
    use get pop* ;

: (parse-lambda) ( words assoc -- lambda )
    push-locals
    \ ] parse-until >quotation <lambda>
    pop-locals ;

: parse-lambda ( words assoc -- )
    (parse-lambda) parsed \ lambda parsed ;

: [|
    #! Literal lambda.
    #! Syntax: [| a b c | ... a ... b ... c ... ]
    parse-locals parse-lambda ; parsing

: (parse-bindings) ( -- )
    scan dup "|" = [
        drop
    ] [
        scan {
            { "[" [ \ ] parse-until >quotation ] }
            { "[|" [ parse-locals (parse-lambda) ] }
        } case 2array ,
        (parse-bindings)
    ] if ;

: parse-bindings ( -- seq )
    [ (parse-bindings) ] { } make ;

: [let
    #! Let form.
    #! Syntax: [let | a [ 1 ] b [ 2 ] ... | ... ]
    scan "|" assert=
    parse-bindings [ values concat [ parsed ] each ] keep keys
    make-locals parse-lambda \ call parsed ; parsing

: [wlet
    #! Let form.
    #! Syntax: [wlet | a [ def1 ] b [ def2 ] ... | ... ]
    scan "|" assert=
    parse-bindings
    [ values [ parsed \ lambda parsed ] each ] keep keys
    make-local-words parse-lambda \ call parsed ; parsing

: (::) ( -- word quot n )
    CREATE dup reset-generic
    scan "|" assert=
    parse-locals push-locals [
        parse-definition (lambda-rewrite)
        swap point-free
    ] keep length
    pop-locals ;

: ::
    #! Word definition with locals.
    #! Syntax: :: name | a b c | ... a ... b ... c ... ;
    (::) drop define-compound ; parsing

: MACRO::
    #! Macro definition with locals.
    #! Syntax: MACRO:: name | a b c | ... a ... b ... c ... ;
    (::) (MACRO:) ; parsing
