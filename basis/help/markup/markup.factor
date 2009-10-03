! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes colors colors.constants
combinators definitions definitions.icons effects fry generic
hashtables help.stylesheet help.topics io io.styles kernel make
math namespaces parser present prettyprint
prettyprint.stylesheet quotations see sequences sets slots
sorting splitting strings vectors vocabs vocabs.loader words ;
FROM: prettyprint.sections => with-pprint ;
IN: help.markup

PREDICATE: simple-element < array
    [ t ] [ first word? not ] if-empty ;

SYMBOL: last-element
SYMBOL: span
SYMBOL: block
SYMBOL: blank-line

: last-span? ( -- ? ) last-element get span eq? ;
: last-block? ( -- ? ) last-element get block eq? ;
: last-blank-line? ( -- ? ) last-element get blank-line eq? ;

: ?nl ( -- )
    last-element get
    last-blank-line? not
    and [ nl ] when ;

: ($span) ( quot -- )
    last-block? [ nl ] when
    span last-element set
    call ; inline

GENERIC: print-element ( element -- )

M: simple-element print-element [ print-element ] each ;
M: string print-element [ write ] ($span) ;
M: array print-element unclip execute( arg -- ) ;
M: word print-element { } swap execute( arg -- ) ;
M: f print-element drop ;

: print-element* ( element style -- )
    [ print-element ] with-style ;

: with-default-style ( quot -- )
    default-span-style get [
        last-element off
        default-block-style get swap with-nesting
    ] with-style ; inline

: print-content ( element -- )
    [ print-element ] with-default-style ;

: ($block) ( quot -- )
    ?nl
    span last-element set
    call
    block last-element set ; inline

! Some spans

: $snippet ( children -- )
    [ snippet-style get print-element* ] ($span) ;

! for help-lint
ALIAS: $slot $snippet

: $emphasis ( children -- )
    [ emphasis-style get print-element* ] ($span) ;

: $strong ( children -- )
    [ strong-style get print-element* ] ($span) ;

: $url ( children -- )
    [
        dup first href associate url-style get assoc-union
        print-element*
    ] ($span) ;

: $nl ( children -- )
    drop nl last-element get [ nl ] when
    blank-line last-element set ;

! Some blocks
: ($heading) ( children quot -- )
    ?nl ($block) ; inline

: $heading ( element -- )
    [ heading-style get print-element* ] ($heading) ;

: $subheading ( element -- )
    [ strong-style get print-element* ] ($heading) ;

: ($code-style) ( presentation -- hash )
    presented associate code-style get assoc-union ;

: ($code) ( presentation quot -- )
    [
        code-char-style get [
            last-element off
            [ ($code-style) ] dip with-nesting
        ] with-style
    ] ($block) ; inline

: $code ( element -- )
    "\n" join dup <input> [ write ] ($code) ;

: $syntax ( element -- ) "Syntax" $heading $code ;

: $description ( element -- )
    "Word description" $heading print-element ;

: $class-description ( element -- )
    "Class description" $heading print-element ;

: $error-description ( element -- )
    "Error description" $heading print-element ;

: $var-description ( element -- )
    "Variable description" $heading print-element ;

: $contract ( element -- )
    "Generic word contract" $heading print-element ;

: $examples ( element -- )
    "Examples" $heading print-element ;

: $example ( element -- )
    1 cut* swap "\n" join dup <input> [
        input-style get format nl print-element
    ] ($code) ;

: $unchecked-example ( element -- )
    #! help-lint ignores these.
    $example ;

: $markup-example ( element -- )
    first dup unparse " print-element" append 1array $code
    print-element ;

: $warning ( element -- )
    [
        warning-style get [
            last-element off
            "Warning" $heading print-element
        ] with-nesting
    ] ($heading) ;

: $deprecated ( element -- )
    [
        deprecated-style get [
            last-element off
            "This word is deprecated" $heading print-element
        ] with-nesting
    ] ($heading) ;

! Images
: $image ( element -- )
    [ first write-image ] ($span) ;

: <$image> ( path -- element )
    1array \ $image prefix ;

! Some links

<PRIVATE

: write-link ( string object -- )
    link-style get [ write-object ] with-style ;

: link-icon ( topic -- )
    definition-icon 1array $image ;

: link-text ( topic -- )
    [ article-name ] keep write-link ;

GENERIC: link-long-text ( topic -- )

M: topic link-long-text
    [ article-title ] keep write-link ;

M: word link-long-text
    dup presented associate [
        [ article-name link-style get format ]
        [ drop bl ]
        [ stack-effect effect>string stack-effect-style get format ]
        tri
    ] with-nesting ;

: >topic ( obj -- topic ) dup topic? [ >link ] unless ;

: topic-span ( topic quot -- ) [ >topic ] dip ($span) ; inline

PRIVATE>

: ($link) ( topic -- ) [ link-text ] topic-span ;
: $link ( element -- ) first ($link) ;

: ($long-link) ( topic -- ) [ link-long-text ] topic-span ;
: $long-link ( element -- ) first ($long-link) ;

: ($pretty-link) ( topic -- )
    [ [ link-icon ] [ drop bl ] [ link-text ] tri ] topic-span ;
: $pretty-link ( element -- ) first ($pretty-link) ;

: ($long-pretty-link) ( topic -- )
    [ [ link-icon ] [ drop bl ] [ link-long-text ] tri ] topic-span ;

: <$pretty-link> ( definition -- element )
    1array \ $pretty-link prefix ;

: ($subsection) ( element quot -- )
    [
        subsection-style get [ call ] with-style
    ] ($block) ; inline

: $subsection* ( topic -- )
    [
        [ ($long-pretty-link) ] with-scope
    ] ($subsection) ;

: $subsections ( children -- )
    [ $subsection* ] each nl nl blank-line last-element set ;

: $subsection ( element -- )
    first $subsection* ;

: ($vocab-link) ( text vocab -- )
    >vocab-link write-link ;

: $vocab-subsection ( element -- )
    [
        first2 dup vocab-help
        [ 2nip ($long-pretty-link) ]
        [ [ >vocab-link link-icon bl ] [ ($vocab-link) ] bi ]
        if*
    ] ($subsection) ;

: $vocab-link ( element -- )
    first dup vocab-name swap ($vocab-link) ;

: $vocabulary ( element -- )
    first vocabulary>> [
        "Vocabulary" $heading nl dup ($vocab-link)
    ] when* ;

: (textual-list) ( seq quot sep -- )
    '[ _ print-element ] swap interleave ; inline

: textual-list ( seq quot -- )
    ", " (textual-list) ; inline

: $links ( topics -- )
    [ [ ($link) ] textual-list ] ($span) ;

: $vocab-links ( vocabs -- )
    [ vocab ] map $links ;

: $breadcrumbs ( topics -- )
    [ [ ($link) ] " > " (textual-list) ] ($span) ;

: $see-also ( topics -- )
    "See also" $heading $links ;

: related-words ( seq -- )
    dup '[ _ "related" set-word-prop ] each ;

: $related ( element -- )
    first dup "related" word-prop remove
    [ $see-also ] unless-empty ;

: ($grid) ( style quot -- )
    [
        table-content-style get [
            swap [ last-element off call ] tabular-output
        ] with-style
    ] ($block) ; inline

: $list ( element -- )
    list-style get [
        [
            [
                bullet get write-cell
                [ print-element ] with-cell
            ] with-row
        ] each
    ] ($grid) ;

: $table ( element -- )
    table-style get [
        [
            [
                [ [ print-element ] with-cell ] each
            ] with-row
        ] each
    ] ($grid) ;

: a/an ( str -- str )
    [ first ] [ length ] bi 1 =
    "afhilmnorsx" "aeiou" ? member? "an" "a" ? ;

GENERIC: ($instance) ( element -- )

M: word ($instance)
    dup name>> a/an write bl ($link) ;

M: string ($instance)
    write ;

M: f ($instance)
    drop { f } $link ;

: $instance ( element -- ) first ($instance) ;

: $or ( element -- )
    dup length {
        { 1 [ first ($instance) ] }
        { 2 [ first2 [ ($instance) " or " print-element ] [ ($instance) ] bi* ] }
        [
            drop
            unclip-last
            [ [ ($instance) ", " print-element ] each ]
            [ "or " print-element ($instance) ]
            bi*
        ]
    } case ;

: $maybe ( element -- )
    f suffix $or ;

: $quotation ( element -- )
    { "a " { $link quotation } " with stack effect " } print-element
    $snippet ;

: values-row ( seq -- seq )
    unclip \ $snippet swap present 2array
    swap dup first word? [ \ $instance prefix ] when 2array ;

: $values ( element -- )
    "Inputs and outputs" $heading
    [ values-row ] map $table ;

: $side-effects ( element -- )
    "Side effects" $heading "Modifies " print-element
    [ $snippet ] textual-list ;

: $errors ( element -- )
    "Errors" $heading print-element ;

: $notes ( element -- )
    "Notes" $heading print-element ;

: ($see) ( word quot -- )
    [
        code-char-style get [
            code-style get swap with-nesting
        ] with-style
    ] ($block) ; inline

: $see ( element -- ) first [ see* ] ($see) ;

: $synopsis ( element -- ) first [ synopsis write ] ($see) ;

: $definition ( element -- )
    "Definition" $heading $see ;

: $methods ( element -- )
    first methods [
        "Methods" $heading
        [ see-all ] ($see)
    ] unless-empty ;

: $value ( object -- )
    "Variable value" $heading
    "Current value in global namespace:" print-element
    first dup [ pprint-short ] ($code) ;

: $curious ( element -- )
    "For the curious..." $heading print-element ;

: $references ( element -- )
    "References" $heading
    unclip print-element [ \ $link swap ] { } map>assoc $list ;

: $shuffle ( element -- )
    drop
    "Shuffle word. Re-arranges the stack according to the stack effect pattern." $description ;

: $low-level-note ( children -- )
    drop
    "Calling this word directly is not necessary in most cases. Higher-level words call it automatically." $notes ;

: $values-x/y ( children -- )
    drop { { "x" number } { "y" number } } $values ;

: $parsing-note ( children -- )
    drop
    "This word should only be called from parsing words."
    $notes ;

: $io-error ( children -- )
    drop
    "Throws an error if the I/O operation fails." $errors ;

: $prettyprinting-note ( children -- )
    drop {
        "This word should only be called from inside the "
        { $link with-pprint } " combinator."
    } $notes ;

GENERIC: elements* ( elt-type element -- )

M: simple-element elements*
    [ elements* ] with each ;

M: object elements* 2drop ;

M: array elements*
    [ [ elements* ] with each ] 2keep
    [ first eq? ] keep swap [ , ] [ drop ] if ;

: elements ( elt-type element -- seq ) [ elements* ] { } make ;

: collect-elements ( element seq -- elements )
    swap '[ _ elements [ rest ] map concat ] map concat prune ;

: <$link> ( topic -- element )
    1array \ $link prefix ;

: <$snippet> ( str -- element )
    1array \ $snippet prefix ;

: $definition-icons ( element -- )
    drop
    icons get >alist sort-keys
    [ [ <$link> ] [ definition-icon-path <$image> ] bi* swap ] assoc-map
    { "" "Definition class" } prefix
    $table ;