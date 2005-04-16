! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: generic hashtables kernel lists math namespaces
presentation stdio streams strings unparser words ;

! Prettyprinting words
: vocab-actions ( search -- list )
    [
        [[ "Words"   "words ."       ]]
        [[ "Use"     "use+" ]]
        [[ "In"      "\"in\" set"    ]]
    ] ;

: vocab-attrs ( vocab -- attrs )
    #! Words without a vocabulary do not get a link or an action
    #! popup.
    unparse vocab-actions <actions> "actions" swons unit ;

: vocab. ( vocab -- ) dup vocab-attrs write-attr ;

: prettyprint-IN: ( word -- )
    \ IN: word-bl word-vocabulary vocab. terpri ;

: prettyprint-prop ( word prop -- )
    tuck word-name word-prop [
        " " write word.
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

: infer-effect. ( effect -- )
    [
        "(" ,
        2unlist >r [ " " , unparse , ] each r>
        " --" ,
        [ " " , unparse , ] each
        " )" ,
    ] make-string comment. ;

: stack-effect. ( word -- )
    dup "stack-effect" word-prop [
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

: definer. ( word -- ) dup definer word-bl word-bl ;

GENERIC: (see) ( word -- )

M: compound (see) ( word -- )
    tab-size get dup indent swap
    [ documentation. ] keep
    [ word-def prettyprint-elements \ ; word. ] keep
    prettyprint-plist terpri drop ;

: prettyprint-M: ( -- indent )
    \ M: word-bl tab-size get ;

: prettyprint-; \ ; word. terpri ;

: method. ( word [[ class method ]] -- )
    uncons >r >r >r prettyprint-M: r> r> word-bl word-bl
    dup prettyprint-newline r> prettyprint-elements
    prettyprint-; drop ;

: generic. ( word -- ) dup methods [ method. ] each-with ;

M: generic (see) ( word -- ) generic. ;

M: 2generic (see) ( word -- ) generic. ;

M: word (see) drop ;

GENERIC: class.

M: union class.
    \ UNION: word-bl
    dup word-bl
    0 swap "members" word-prop prettyprint-elements drop
    prettyprint-; ;

M: complement class.
    \ COMPLEMENT: word-bl
    dup word-bl
    "complement" word-prop word. terpri ;

M: builtin class.
    \ BUILTIN: word-bl
    dup word-bl
    dup "builtin-type" word-prop unparse write " " write
    0 swap "slots" word-prop prettyprint-elements drop
    prettyprint-; ;

M: predicate class.
    \ PREDICATE: word-bl
    dup "superclass" word-prop word-bl
    dup word-bl
    tab-size get dup prettyprint-newline swap
    "definition" word-prop prettyprint-elements drop
    prettyprint-; ;

M: tuple-class class.
    \ TUPLE: word-bl
    dup word-bl
    "slot-names" word-prop [ write " " write ] each
    prettyprint-; ;

M: word class. drop ;

: see ( word -- )
    dup prettyprint-IN: dup definer.
    dup stack-effect. terpri dup (see) class. ;

: methods. ( class -- )
    #! List all methods implemented for this class.
    dup class.
    dup implementors [
        dup prettyprint-IN:
        [ "methods" word-prop hash* ] keep swap method.
    ] each-with ;
