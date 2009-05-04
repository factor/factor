! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays io io.styles kernel namespaces make
parser prettyprint sequences words words.symbol assocs
definitions generic quotations effects slots continuations
classes.tuple debugger combinators vocabs help.stylesheet
help.topics help.crossref help.markup sorting classes
vocabs.loader ;
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
        first "predicating" word-prop <$link> ,
        " class." ,
    ] { } make $description ;

M: word word-help* drop f ;

M: predicate word-help* drop \ $predicate ;

: all-articles ( -- seq )
    articles get keys
    all-words [ word-help ] filter append ;

: orphan-articles ( -- seq )
    articles get keys
    [ article-parent not ] filter ;

: xref-help ( -- )
    all-articles [ xref-article ] each ;

: error? ( word -- ? )
    \ $error-description swap word-help elements empty? not ;

: sort-articles ( seq -- newseq )
    [ dup article-title ] { } map>assoc sort-values keys ;

: all-errors ( -- seq )
    all-words [ error? ] filter sort-articles ;

M: word article-name name>> ;

M: word article-title
    dup [ parsing-word? ] [ symbol? ] bi or [
        name>> 
    ] [
        [ unparse ]
        [ stack-effect [ effect>string " " prepend ] [ "" ] if* ] bi
        append
    ] if ;

<PRIVATE

: (word-help) ( word -- element )
    [
        {
            [ \ $vocabulary swap 2array , ]
            [ word-help % ]
            [ \ $related swap 2array , ]
            [ get-global [ \ $value swap 2array , ] when* ]
            [ \ $definition swap 2array , ]
        } cleave
    ] { } make ;

M: word article-content (word-help) ;

<PRIVATE

: word-with-methods ( word -- elements )
    [
        [ (word-help) % ]
        [ \ $methods swap 2array , ]
        bi
    ] { } make ;

PRIVATE>

M: generic article-content word-with-methods ;

M: class article-content word-with-methods ;

M: word article-parent "help-parent" word-prop ;

M: word set-article-parent swap "help-parent" set-word-prop ;

: ($title) ( topic -- )
    [ [ article-title ] [ >link ] bi write-object ] ($block) ;

: $navigation-row ( content element label -- )
    [ prefix 1array ] dip prefix , ;

: $navigation-table ( topic -- )
    [
        [ help-path [ \ $links "Up:" $navigation-row ] unless-empty ]
        [ prev-article [ 1array \ $long-link "Prev:" $navigation-row ] when* ]
        [ next-article [ 1array \ $long-link "Next:" $navigation-row ] when* ]
        tri
    ] { } make [ $table ] unless-empty ;

: $title ( topic -- )
    title-style get [
        title-style get [
            [ ($title) ]
            [ help-path-style get [ $navigation-table ] with-style ] bi
        ] with-nesting
    ] with-style nl ;

: print-topic ( topic -- )
    >link
    last-element off
    [ $title ] [ article-content print-content nl ] bi ;

SYMBOL: help-hook

help-hook [ [ print-topic ] ] initialize

: help ( topic -- )
    help-hook get call( topic -- ) ;

: ($index) ( articles -- )
    sort-articles [ \ $subsection swap 2array ] map print-element ;

: $index ( element -- )
    first call( -- seq ) [ ($index) ] unless-empty ;

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

: (:help) ( error -- )
    error-help [ help ] [ "No help for this error. " print ] if*
    :help-debugger ;

: :help ( -- )
    error get (:help) ;

: remove-article ( name -- )
    articles get delete-at ;

: add-article ( article name -- )
    [ remove-article ] keep
    [ articles get set-at ] keep
    xref-article ;

: remove-word-help ( word -- )
    f "help" set-word-prop ;

: set-word-help ( content word -- )
    [ remove-word-help ] keep
    [ swap "help" set-word-prop ] keep
    xref-article ;
