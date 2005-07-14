! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: generic hashtables io kernel lists namespaces sequences
streams strings styles unparser words ;

: prettyprint-IN: ( word -- )
    \ IN: unparse. bl word-vocabulary write terpri ;

: prettyprint-prop ( word prop -- )
    tuck word-name word-prop [
        bl unparse.
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
        [[ "fg" [ 255 0 0 ] ]]
        [[ foreground [ 192 0 0 ] ]]
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
            "#!" swap append comment.
            dup prettyprint-newline
        ] each
    ] when* ;

: definer. ( word -- ) dup definer unparse. bl unparse. bl ;

GENERIC: (see) ( word -- )

M: compound (see) ( word -- )
    tab-size get dup indent swap
    [ documentation. ] keep
    [ word-def prettyprint-elements \ ; unparse. ] keep
    prettyprint-plist terpri drop ;

: prettyprint-M: ( -- indent )
    \ M: unparse. bl tab-size get ;

: prettyprint-; \ ; unparse. terpri ;

: method. ( word [[ class method ]] -- )
    uncons >r >r >r prettyprint-M: r> r> unparse. bl unparse. bl
    dup prettyprint-newline r> prettyprint-elements
    prettyprint-; drop ;

M: generic (see) ( word -- )
    tab-size get dup indent [
        one-line on
        over "picker" word-prop prettyprint* bl
        over "dispatcher" word-prop prettyprint* bl
    ] with-scope
    drop
    \ ; unparse. terpri
    dup methods [ method. ] each-with ;

M: word (see) drop ;

GENERIC: class.

M: union class.
    \ UNION: unparse. bl
    dup unparse. bl
    0 swap "members" word-prop prettyprint-elements drop
    prettyprint-; ;

M: complement class.
    \ COMPLEMENT: unparse. bl
    dup unparse. bl
    "complement" word-prop unparse. terpri ;

M: builtin class.
    \ BUILTIN: unparse. bl
    dup unparse. bl
    dup "builtin-type" word-prop unparse write bl
    0 swap "slots" word-prop prettyprint-elements drop
    prettyprint-; ;

M: predicate class.
    \ PREDICATE: unparse. bl
    dup "superclass" word-prop unparse. bl
    dup unparse. bl
    tab-size get dup prettyprint-newline swap
    "definition" word-prop prettyprint-elements drop
    prettyprint-; ;

M: tuple-class class.
    \ TUPLE: unparse. bl
    dup unparse. bl
    "slot-names" word-prop [ write bl ] each
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
