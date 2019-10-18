! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: generic kernel lists math namespaces stdio strings
presentation streams unparser words ;

! Prettyprinting words
: vocab-actions ( search -- list )
    [
        [[ "Words"   "words."        ]]
        [[ "Use"     "\"use\" cons@" ]]
        [[ "In"      "\"in\" set"    ]]
    ] ;

: vocab-attrs ( vocab -- attrs )
    #! Words without a vocabulary do not get a link or an action
    #! popup.
    unparse vocab-actions <actions> "actions" swons unit ;

: prettyprint-vocab ( vocab -- )
    dup vocab-attrs write-attr ;

: prettyprint-IN: ( word -- )
    \ IN: prettyprint-word " " write
    word-vocabulary prettyprint-vocab " " write ;

: prettyprint-: ( indent -- indent )
    \ : prettyprint-word " " write
    tab-size get + ;

: prettyprint-; ( indent -- indent )
    \ ; prettyprint-word
    tab-size get - ;

: prettyprint-prop ( word prop -- )
    tuck word-name word-prop [
        " " write prettyprint-word
    ] [
        drop
    ] ifte ;

: prettyprint-plist ( word -- )
    dup
    \ parsing prettyprint-prop
    \ inline prettyprint-prop ;

: comment-style
    #! Feel free to redefine this!
    [
        [[ "ansi-fg" "0" ]]
        [[ "ansi-bg" "2" ]]
        [[ "fg" [ 255 0 0 ] ]]
    ] ;

: comment. ( comment -- ) comment-style write-attr ;

: infer-effect. ( indent effect -- indent )
    " " write
    [
        "(" ,
        2unlist >r [ " " , unparse , ] each r>
        " --" ,
        [ " " , unparse , ] each
        " )" ,
    ] make-string comment. ;

: stack-effect. ( indent word -- indent )
    dup "stack-effect" word-prop [
        " " write
        [ CHAR: ( , , CHAR: ) , ] make-string
        comment.
    ] [
        "infer-effect" word-prop dup [
            infer-effect.
        ] [
            drop
        ] ifte
    ] ?ifte ;

: documentation. ( indent word -- indent )
    "documentation" word-prop [
        "\n" split [
            "#!" swap cat2 comment.
            dup prettyprint-newline
        ] each
    ] when* ;

: prettyprint-docs ( indent word -- indent )
    [
        stack-effect. dup prettyprint-newline
    ] keep documentation. ;

: prettyprint-M: ( indent -- indent )
    \ M: prettyprint-word " " write tab-size get + ;

GENERIC: see ( word -- )

M: compound see ( word -- )
    dup prettyprint-IN:
    0 prettyprint-: swap
    [ prettyprint-word ] keep
    [ prettyprint-docs ] keep
    [ word-def prettyprint-elements prettyprint-; ] keep
    prettyprint-plist prettyprint-newline ;

: see-method ( indent word class method -- indent )
    >r >r >r prettyprint-M:
    r> r> prettyprint-word " " write
    prettyprint-word " " write
    dup prettyprint-newline
    r> prettyprint-elements
    prettyprint-;
    terpri ;

: see-generic ( word definer -- )
    >r dup prettyprint-IN:
    0 swap
    r> prettyprint-word " " write
    dup prettyprint-word terpri
    dup methods [ over >r uncons see-method r> ] each 2drop ;

M: generic see ( word -- )
    \ GENERIC: see-generic ;

M: 2generic see ( word -- )
    \ 2GENERIC: see-generic ;

M: primitive see ( word -- )
    dup prettyprint-IN:
    "PRIMITIVE: " write dup prettyprint-word stack-effect.
    terpri ;

M: symbol see ( word -- )
    dup prettyprint-IN:
    \ SYMBOL: prettyprint-word " " write . ;

M: undefined see ( word -- )
    dup prettyprint-IN:
    \ DEFER: prettyprint-word " " write . ;
