! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io kernel namespaces parser prettyprint sequences
words assocs definitions generic quotations effects slots
continuations classes.tuple debugger combinators vocabs
help.stylesheet help.topics help.crossref help.markup sorting
classes vocabs.loader ;
IN: help

GENERIC: word-help* ( word -- content )

: word-help ( word -- content )
    dup "help" word-prop [ ] [
        dup word-help* dup
        [ swap 2array 1array ] [ 2drop f ] if
    ] ?if ;

: $predicate ( element -- )
    { { "object" object } { "?" "a boolean" } } $values
    [
        "Tests if the object is an instance of the " ,
        first "predicating" word-prop \ $link swap 2array ,
        " class." ,
    ] { } make $description ;

M: word word-help* drop f ;

M: predicate word-help* drop \ $predicate ;

: all-articles ( -- seq )
    articles get keys
    all-words [ word-help ] filter append ;

: xref-help ( -- )
    all-articles [ xref-article ] each ;

: error? ( word -- ? )
    \ $error-description swap word-help elements empty? not ;

: sort-articles ( seq -- newseq )
    [ dup article-title ] { } map>assoc sort-values keys ;

: all-errors ( -- seq )
    all-words [ error? ] filter sort-articles ;

M: word article-name word-name ;

M: word article-title
    dup [ parsing-word? ] [ symbol? ] bi or [
        word-name
    ] [
        [ word-name ]
        [ stack-effect [ effect>string " " prepend ] [ "" if ] if* ] bi
        append
    ] if ;

M: word article-content
    [
        \ $vocabulary over 2array ,
        dup word-help %
        \ $related over 2array ,
        dup get-global [ \ $value swap 2array , ] when*
        \ $definition swap 2array ,
    ] { } make ;

M: word article-parent "help-parent" word-prop ;

M: word set-article-parent swap "help-parent" set-word-prop ;

: $doc-path ( article -- )
    help-path dup empty? [
        drop
    ] [
        [
            help-path-style get [
                "Parent topics: " write $links
            ] with-style
        ] ($block)
    ] if ;

: $title ( topic -- )
    title-style get [
        title-style get [
            dup [
                dup article-title swap >link write-object
            ] ($block) $doc-path
        ] with-nesting
    ] with-style nl ;

: help ( topic -- )
    last-element off dup $title
    article-content print-content nl ;

: about ( vocab -- )
    dup require
    dup vocab [ ] [
        "No such vocabulary: " prepend throw
    ] ?if
    dup vocab-help [
        help
    ] [
        "The " write vocab-name write
        " vocabulary does not define a main help article." print
        "To define one, refer to \\ ABOUT: help" print
    ] ?if ;

: ($index) ( articles -- )
    sort-articles [ \ $subsection swap 2array ] map print-element ;

: $index ( element -- )
    first call dup empty?
    [ drop ] [ [ ($index) ] ($block) ] if ;

: $about ( element -- )
    first vocab-help [ 1array $subsection ] when* ;

: :help-debugger ( -- )
    nl
    "Debugger commands:" print
    nl
    ":s    - data stack at error time" print
    ":r    - retain stack at error time" print
    ":c    - call stack at error time" print
    ":edit - jump to source location (parse errors only)" print

    ":get  ( var -- value ) accesses variables at time of the error" print
    ":vars - list all variables at error time" print ;

: :help ( -- )
    error get error-help [ help ] [ "No help for this error. " print ] if
    :help-debugger ;

: remove-article ( name -- )
    dup articles get key? [
        dup unxref-article
        dup articles get delete-at
    ] when drop ;

: add-article ( article name -- )
    [ remove-article ] keep
    [ articles get set-at ] keep
    xref-article ;

: remove-word-help ( word -- )
    dup word-help [ dup unxref-article ] when
    f "help" set-word-prop ;

: set-word-help ( content word -- )
    [ remove-word-help ] keep
    [ swap "help" set-word-prop ] keep
    xref-article ;
