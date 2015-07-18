! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.tuple
combinators combinators.short-circuit continuations debugger
effects generic help.crossref help.markup help.stylesheet
help.topics io io.styles kernel make namespaces prettyprint
sequences sorting vocabs words words.symbol ;
IN: help

GENERIC: word-help* ( word -- content )

: word-help ( word -- content )
    dup "help" word-prop [ ] [
        dup word-help* dup
        [ swap 2array 1array ] [ 2drop f ] if
    ] ?if ;

: $predicate ( element -- )
    { { "object" object } { "?" boolean } } $values
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
    [ article-parent ] reject ;

: xref-help ( -- )
    all-articles [ xref-article ] each ;

: error? ( word -- ? )
    {
        [ error-class? ]
        [ \ $error-description swap word-help elements empty? not ]
    } 1|| ;

: sort-articles ( seq -- newseq )
    [ dup article-title ] { } map>assoc sort-values keys ;

: all-errors ( -- seq )
    all-words [ error? ] filter sort-articles ;

M: word valid-article? drop t ;

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
            [ dup is-global [ get-global \ $value swap 2array , ] [ drop ] if ]
            [ \ $definition swap 2array , ]
        } cleave
    ] { } make ;

M: word article-content (word-help) ;

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

: ($navigation-table) ( element -- )
    help-path-style get table-style [ $table ] with-variable ;

: $navigation-table ( topic -- )
    [
        [ prev-article [ 1array \ $long-link "Prev:" $navigation-row ] when* ]
        [ next-article [ 1array \ $long-link "Next:" $navigation-row ] when* ]
        bi
    ] { } make [ ($navigation-table) ] unless-empty ;

: ($navigation-path) ( topic -- )
    help-path-style get
       [ help-path [ reverse $breadcrumbs ] unless-empty ]
    with-style ;

: ($navigation-prev-next) ( topic -- )
    help-path-style get 
       [ $navigation-table ]
    with-style ;

: $title ( topic -- )
    title-style get [
        title-style get [
            [ ($title) ] [ ($navigation-path) ] bi
        ] with-nesting
    ] with-style ;

: print-topic ( topic -- )
    >link
    last-element off
    [ nl article-content print-content nl ] 
    [ ($blank-line) ($navigation-prev-next) ] 
    bi ;

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
