! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.units
definitions.icons effects english hashtables help.stylesheet
help.topics io io.styles kernel make math namespaces present
prettyprint prettyprint.stylesheet quotations see sequences
sequences.private sets sorting splitting strings urls vocabs
words words.symbol ;
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

: ($blank-line) ( -- )
    nl nl blank-line last-element namespaces:set ;

: ($span) ( quot -- )
    last-block? [ nl ] when
    span last-element namespaces:set
    call ; inline

GENERIC: print-element ( element -- )

M: simple-element print-element [ print-element ] each ;
M: string print-element [ write ] ($span) ;
M: array print-element unclip execute( arg -- ) ;
M: word print-element { } swap execute( arg -- ) ;
M: effect print-element effect>string print-element ;
M: f print-element drop ;

: print-element* ( element style -- )
    [ print-element ] with-style ;

: with-default-style ( quot -- )
    default-style get swap with-nesting ; inline

: print-content ( element -- )
    [ print-element ] with-default-style ;

: ($block) ( quot -- )
    ?nl
    span last-element namespaces:set
    call
    block last-element namespaces:set ; inline

! Some spans

: $snippet ( children -- )
    [ snippet-style get print-element* ] ($span) ;

: $emphasis ( children -- )
    [ emphasis-style get print-element* ] ($span) ;

: $strong ( children -- )
    [ strong-style get print-element* ] ($span) ;

: $url ( children -- )
    [ ?second ] [ first ] bi [ or ] keep >url [
        dup present href associate url-style get assoc-union
        [ write-object ] with-style
    ] ($span) ;

: $nl ( children -- )
    drop nl last-element get [ nl ] when
    blank-line last-element namespaces:set ;

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
        last-element off
        [ ($code-style) ] dip with-nesting
    ] ($block) ; inline

: $code ( element -- )
    join-lines dup <input> [ write ] ($code) ;

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
    unclip-last [ join-lines ] dip over <input> [
        [ print ] [ output-style get format ] bi*
    ] ($code) ;

: $unchecked-example ( element -- )
    ! help-lint ignores these.
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

GENERIC: link-effect? ( word -- ? )

M: parsing-word link-effect? drop f ;
M: symbol link-effect? drop f ;
M: word link-effect? drop t ;

: $effect ( effect -- )
    effect>string base-effect-style get format ;

M: word link-long-text
    dup presented associate [
        [ article-name link-style get format ]
        [
            dup link-effect? [
                bl stack-effect $effect
            ] [ drop ] if
        ] bi
    ] with-nesting ;

: >topic ( obj -- topic ) dup topic? [ >link ] unless ;

: topic-span ( topic quot -- ) [ >topic ] dip ($span) ; inline

! Turns "foo.bar" into { { "foo" } { "foo" "bar" } }
: vocab-breadcrumbs ( vocab -- vocab-list )
    "." split { } [ suffix ] accumulate* ;

ERROR: number-of-arguments found required ;

: check-first ( seq -- first )
    dup length 1 = [ length 1 number-of-arguments ] unless
    first-unsafe ;

: check-first2 ( seq -- first second )
    dup length 2 = [ length 2 number-of-arguments ] unless
    first2-unsafe ;

PRIVATE>

: ($link) ( topic -- ) [ link-text ] topic-span ;

: $link ( element -- ) check-first ($link) ;

: ($long-link) ( topic -- ) [ link-long-text ] topic-span ;

: $long-link ( element -- ) check-first ($long-link) ;

: ($pretty-link) ( topic -- )
    [ [ link-icon ] [ drop bl ] [ link-text ] tri ] topic-span ;

: $pretty-link ( element -- ) check-first ($pretty-link) ;

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
    [ $subsection* ] each ($blank-line) ;

: $subsection ( element -- )
    check-first $subsection* ;

: ($vocab-breadcrumb-links) ( vocab -- )
    vocab-breadcrumbs
    [ "." write ] [ [ last ] [ "." join ] bi >vocab-link write-link ]
    interleave ;

: ($vocab-link) ( text vocab -- )
    ! If the link text is just the vocabulary name, split it into
    ! separate links for each parent vocabulary.
    2dup = [ drop ($vocab-breadcrumb-links) ] [ >vocab-link write-link ] if ;

: $vocab-subsection ( element -- )
    [
        check-first2 dup vocab-help
        [ 2nip ($long-pretty-link) ]
        [ [ >vocab-link link-icon bl ] [ ($vocab-link) ] bi ]
        if*
    ] ($subsection) ;

: $vocab-subsections ( element -- )
    [ $vocab-subsection ] each ($blank-line) ;

: $vocab-link ( element -- )
    check-first [ vocab-name ] keep ($vocab-link) ;

: $vocabulary ( element -- )
    check-first vocabulary>> [
        "Vocabulary" $heading nl dup ($vocab-link)
    ] when* ;

: (textual-list) ( seq quot sep -- )
    '[ _ print-element ] swap interleave ; inline

: textual-list ( seq quot -- )
    ", " (textual-list) ; inline

: $links ( topics -- )
    [ [ ($link) ] textual-list ] ($span) ;

: $vocab-links ( vocabs -- )
    [ lookup-vocab ] map $links ;

: $breadcrumbs ( topics -- )
    [ [ ($link) ] " » " (textual-list) ] ($span) ;

: $see-also ( topics -- )
    "See also" $heading $links ;

<PRIVATE
:: update-related-words ( words -- affected-words )
    words words [| affected word |
        word "related" [ affected union words ] change-word-prop
    ] reduce ;

:: clear-unrelated-words ( words affected-words -- )
    affected-words words diff
    [ "related" [ words diff ] change-word-prop ] each ;

: notify-related-words ( affected-words -- )
    fast-set notify-definition-observers ;

PRIVATE>

: related-words ( seq -- )
    dup update-related-words
    [ clear-unrelated-words ] [ notify-related-words ] bi ;

: $related ( element -- )
    check-first dup "related" word-prop remove
    [ $see-also ] unless-empty ;

: ($grid) ( style content-style quot -- )
    '[
        _ [ last-element off _ tabular-output ] with-style
    ] ($block) ; inline

: $list ( element -- )
    list-style get list-content-style get [
        [
            [
                bullet get write-cell
                [ print-element ] with-cell
            ] with-row
        ] each
    ] ($grid) ;

: $table ( element -- )
    table-style get table-content-style get [
        [
            [
                [ [ print-element ] with-cell ] each
            ] with-row
        ] each
    ] ($grid) ;

! for help-lint
ALIAS: $slot $snippet

: $slots ( children -- )
    [ unclip \ $slot swap 2array prefix ] map $table ;

: a/an ( str -- str )
    [ first ] [ length ] bi 1 =
    "afhilmnorsx" vowels ? member? "an" "a" ? ;

GENERIC: ($instance) ( element -- )

M: word ($instance) dup name>> a/an write bl ($link) ;

M: string ($instance) write ;

M: array ($instance) print-element ;

M: f ($instance) ($link) ;

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
    check-first
    { "a " { $link quotation } " with stack effect " }
    print-element $snippet ;

: ($instances) ( element -- )
    dup word? [ ($link) "s" print-element ] [ print-element ] if ;

: $sequence ( element -- )
    { "a " { $link sequence } " of " } print-element
    dup length {
        { 1 [ first ($instances) ] }
        { 2 [ first2 [ ($instances) " or " print-element ] [ ($instances) ] bi* ] }
        [
            drop
            unclip-last
            [ [ ($instances) ", " print-element ] each ]
            [ "or " print-element ($instances) ]
            bi*
        ]
    } case ;

: values-row ( seq -- seq )
    unclip \ $snippet swap present 2array
    swap dup first word? [ \ $instance prefix ] when 2array ;

: ($values) ( element -- )
    [ [ "None" write ] ($block) ]
    [ [ values-row ] map $table ] if-empty ;

: $inputs ( element -- )
    "Inputs" $heading ($values) ;

: $outputs ( element -- )
    "Outputs" $heading ($values) ;

: $values ( element -- )
    "Inputs and outputs" $heading ($values) ;

: $side-effects ( element -- )
    "Side effects" $heading "Modifies " print-element
    [ $snippet ] textual-list ;

: $errors ( element -- )
    "Errors" $heading print-element ;

: $notes ( element -- )
    "Notes" $heading print-element ;

: ($see) ( word quot -- )
    [ code-style get swap with-nesting ] ($block) ; inline

: $see ( element -- ) check-first [ see* ] ($see) ;

: $synopsis ( element -- ) check-first [ synopsis write ] ($see) ;

: $definition ( element -- )
    "Definition" $heading $see ;

: $methods ( element -- )
    check-first methods [
        "Methods" $heading
        [ see-all ] ($see)
    ] unless-empty ;

: $value ( object -- )
    "Variable value" $heading
    "Current value in global namespace:" print-element
    check-first dup [ pprint-short ] ($code) ;

: $curious ( element -- )
    "For the curious..." $heading print-element ;

: $references ( element -- )
    "References" $heading
    unclip print-element [ \ $link swap ] map>alist $list ;

: $shuffle ( element -- )
    "This is a shuffle word, rearranging the top of the datastack as indicated by the word's stack effect" swap
    ?first [ ": " swap "." 4array ] [ "." append ] if*
    $description ;

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

: $content ( element -- )
    first article-content print-content nl ;

GENERIC: elements* ( elt-type element -- )

M: simple-element elements*
    [ elements* ] with each ;

M: object elements* 2drop ;

M: array elements*
    [ dup first \ $markup-example eq? [ 2drop ] [ [ elements* ] with each ] if ]
    [ [ first eq? ] 1check [ , ] [ drop ] if ] 2bi ;

: elements ( elt-type element -- seq ) [ elements* ] { } make ;

: collect-elements ( element seq -- elements )
    swap '[ [ _ elements* ] each ] { } make [ rest ] map concat ;

: <$link> ( topic -- element )
    1array \ $link prefix ;

: <$snippet> ( str -- element )
    1array \ $snippet prefix ;

: $definition-icons ( element -- )
    drop
    icons get sort-keys
    [ [ <$link> ] [ definition-icon-path <$image> ] bi* swap ] assoc-map
    { f { $strong "Definition class" } } prefix
    $table ;
