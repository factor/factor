! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: generic kernel lists math namespaces stdio strings
presentation unparser words ;

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
    \ IN: prettyprint* " " write
    word-vocabulary prettyprint-vocab " " write ;

: prettyprint-: ( indent -- indent )
    \ : prettyprint* " " write
    tab-size get + ;

: prettyprint-; ( indent -- indent )
    \ ; prettyprint*
    tab-size get - ;

: prettyprint-prop ( word prop -- )
    tuck word-name word-property [
        " " write prettyprint-1
    ] [
        drop
    ] ifte ;

: prettyprint-plist ( word -- )
    dup
    \ parsing prettyprint-prop
    \ inline prettyprint-prop ;

: prettyprint-comment ( comment -- )
    "comments" style write-attr ;

: stack-effect. ( word -- )
    stack-effect [
        " " write
        [ CHAR: ( , , CHAR: ) , ] make-string prettyprint-comment
    ] when* ;

: documentation. ( indent word -- indent )
    documentation [
        "\n" split [
            "#!" swap cat2 prettyprint-comment
            dup prettyprint-newline
        ] each
    ] when* ;

: prettyprint-docs ( indent word -- indent )
    [
        stack-effect. dup prettyprint-newline
    ] keep documentation. ;

: prettyprint-M: ( indent -- indent )
    \ M: prettyprint-1 " " write tab-size get + ;

GENERIC: see ( word -- )

M: compound see ( word -- )
    dup prettyprint-IN:
    0 prettyprint-: swap
    [ prettyprint-1 ] keep
    [ prettyprint-docs ] keep
    [
        word-parameter [ prettyprint-element ] each
        prettyprint-;
    ] keep
    prettyprint-plist prettyprint-newline ;

: see-method ( indent word class method -- indent )
    >r >r >r prettyprint-M:
    r> r> prettyprint-1 " " write
    prettyprint-1 " " write
    dup prettyprint-newline
    r> [ prettyprint-element ] each
    prettyprint-;
    terpri ;

M: generic see ( word -- )
    dup prettyprint-IN:
    0 swap
    dup "definer" word-property prettyprint-1 " " write
    dup prettyprint-1 terpri
    dup methods [ over >r uncons see-method r> ] each 2drop ;

M: primitive see ( word -- )
    dup prettyprint-IN:
    "PRIMITIVE: " write dup prettyprint-1 stack-effect. terpri ;

M: symbol see ( word -- )
    dup prettyprint-IN:
    \ SYMBOL: prettyprint-1 " " write . ;

M: undefined see ( word -- )
    dup prettyprint-IN:
    \ DEFER: prettyprint-1 " " write . ;
