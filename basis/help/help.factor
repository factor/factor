! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.error combinators
combinators.short-circuit continuations debugger effects fry
generic help.crossref help.markup help.stylesheet help.topics io
io.styles kernel make namespaces prettyprint sequences sets
sorting vocabs words words.alias words.symbol ;
IN: help

GENERIC: word-help* ( word -- content )

<PRIVATE

: inputs-and-outputs ( content word -- content' word )
   over [ dup array? [ { $values } head? ] [ drop f ] if ] find drop [
        '[ _ cut unclip rest ] dip [
            stack-effect [ in>> ] [ out>> ] bi
            [ [ dup pair? [ first ] when ] map ] bi@
            [ '[ ?first _ member? ] filter ] bi-curry@
            \ $inputs \ $outputs
            [ '[ @ _ prefix ] ] bi-curry@ bi* bi
            2array glue
        ] keep
    ] when* ;

: fix-shuffle ( content word -- content' word )
    over [ \ $shuffle = ] find drop [
        '[ _ cut unclip ] dip [
            stack-effect 2array 1array glue
        ] keep
    ] when* ;

PRIVATE>

: word-help ( word -- content )
    [ [ "help" word-prop ] [ word-help* ] ?unless ] keep
    inputs-and-outputs fix-shuffle drop ;

: effect-help ( effect -- content )
    [ in>> ] [ out>> ] bi [
        [
            dup pair? [
                first2 dup effect? [ \ $quotation swap 2array ] when
            ] [
                object
            ] if [ effect>string ] dip
        ] map>alist
    ] bi@ \ $inputs \ $outputs [ prefix ] bi-curry@ bi* 2array ;

M: word word-help* stack-effect effect-help ;

: $predicate ( element -- )
    { { "object" object } { "?" boolean } } $values
    [
        "Tests if the object is an instance of the " ,
        first "predicating" word-prop <$link> ,
        " class." ,
    ] { } make $description ;

M: predicate word-help* \ $predicate swap 2array 1array ;

M: class word-help* drop f ;

M: alias word-help*
    [
        \ $description ,
        "An alias for " , def>> first <$link> , "." ,
    ] { } make 1array ;

: all-articles ( -- seq )
    articles get keys
    all-words [ word-help ] filter append ;

: orphan-articles ( -- seq )
    articles get keys [ article-parent ] reject
    { "help.home" "handbook" } diff ;

: xref-help ( -- )
    all-articles [ xref-article ] each ;

: error? ( word -- ? )
    {
        [ error-class? ]
        [ \ $error-description swap word-help elements empty? not ]
    } 1|| ;

: sort-articles ( seq -- newseq )
    [ article-title ] zip-with sort-values keys ;

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
            [ dup global at [ get-global \ $value swap 2array , ] [ drop ] if ]
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

: ($navigation-table) ( element -- )
    help-path-style get dup [
        table-style [ $table ] with-variable
    ] with-style ;

: ($navigation-path) ( topic -- )
    help-path-style get [
       help-path [ reverse $breadcrumbs ] unless-empty
    ] with-style ;

: ($navigation-link) ( content element label -- )
    [ prefix 1array ] dip prefix , ;

: ($navigation-links) ( topic -- )
    [
        [ prev-article [ 1array \ $long-link "Prev:" ($navigation-link) ] when* ]
        [ next-article [ 1array \ $long-link "Next:" ($navigation-link) ] when* ]
        bi
    ] { } make [ ($navigation-table) ] unless-empty ;

: $title ( topic -- )
    title-style get [
        [ ($title) ]
        [ ($navigation-path) ]
        [ ($navigation-links) ] tri
    ] with-nesting ;

: print-topic ( topic -- )
    >link
    last-element off
    [ $title ($blank-line) ]
    [ article-content print-content nl ] bi ;

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
    [ articles get set-at ] keep xref-article ;

: remove-word-help ( word -- )
    "help" remove-word-prop ;

: set-word-help ( content word -- )
    [ swap "help" set-word-prop ] keep xref-article ;
