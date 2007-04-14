! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic io kernel assocs hashtables
namespaces parser prettyprint sequences strings io.styles
vectors words math sorting splitting classes
slots vocabs help.stylesheet help.topics vocabs.loader ;
IN: help.markup

! Simple markup language.

! <element> ::== <string> | <simple-element> | <fancy-element>
! <simple-element> ::== { <element>* }
! <fancy-element> ::== { <type> <element> }

! Element types are words whose name begins with $.

PREDICATE: simple-element < array
    dup empty? [ drop t ] [ first word? not ] if ;

SYMBOL: last-element
SYMBOL: span
SYMBOL: block
SYMBOL: table

: last-span? last-element get span eq? ;
: last-block? last-element get block eq? ;

: ($span) ( quot -- )
    last-block? [ nl ] when
    span last-element set
    call ; inline

GENERIC: print-element ( element -- )

M: simple-element print-element [ print-element ] each ;
M: string print-element [ write ] ($span) ;
M: array print-element unclip execute ;
M: word print-element { } swap execute ;
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
    last-element get { f table } member? [ nl ] unless
    span last-element set
    call
    block last-element set ; inline

! Some spans

: $snippet [ snippet-style get print-element* ] ($span) ;

: $emphasis [ emphasis-style get print-element* ] ($span) ;

: $strong [ strong-style get print-element* ] ($span) ;

: $url [ url-style get print-element* ] ($span) ;

: $nl nl nl drop ;

! Some blocks
: ($heading)
    last-element get [ nl ] when ($block) ; inline

: $heading ( element -- )
    [ heading-style get print-element* ] ($heading) ;

: $subheading ( element -- )
    [ strong-style get print-element* ] ($heading) ;

: ($code-style) ( presentation -- hash )
    presented associate code-style get union ;

: ($code) ( presentation quot -- )
    [
        snippet-style get [
            last-element off
            >r ($code-style) r> with-nesting
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

! Some links
: write-link ( string object -- )
    link-style get [ write-object ] with-style ;

: ($link) ( article -- )
    dup article-name swap >link write-link
    span last-element set ;

: $link ( element -- )
    first ($link) ;

: ($long-link) ( object -- )
    dup article-title swap >link write-link ;

: ($subsection) ( element quot -- )
    [
        subsection-style get [
            bullet get write bl
            call
        ] with-style
    ] ($block) ; inline

: $subsection ( element -- )
    [ first ($long-link) ] ($subsection) ;

: ($vocab-link) ( text vocab -- )
    >vocab-link write-link ;

: $vocab-subsection ( element -- )
    [
        first2 dup vocab-help dup [
            2nip ($long-link)
        ] [
            drop ($vocab-link)
        ] if
    ] ($subsection) ;

: $vocab-link ( element -- )
    first dup vocab-name swap ($vocab-link) ;

: $vocabulary ( element -- )
    first word-vocabulary [
        "Vocabulary" $heading nl dup ($vocab-link)
    ] when* ;

: textual-list ( seq quot -- )
    [ ", " print-element ] swap interleave ; inline

: $links ( topics -- )
    [ [ ($link) ] textual-list ] ($span) ;

: $see-also ( topics -- )
    "See also" $heading $links ;

: related-words ( seq -- )
    dup [ "related" set-word-prop ] curry each ;

: $related ( element -- )
    first dup "related" word-prop remove dup empty?
    [ drop ] [ $see-also ] if ;

: ($grid) ( style quot -- )
    [
        table-content-style get [
            swap [ last-element off call ] tabular-output
        ] with-style
    ] ($block) table last-element set ; inline

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
    first "aeiou" member? "an" "a" ? ;

GENERIC: ($instance) ( element -- )

M: word ($instance)
    dup word-name a/an write bl ($link) ;

M: string ($instance)
    dup a/an write bl $snippet ;

: $instance first ($instance) ;

: values-row ( seq -- seq )
    unclip \ $snippet swap ?word-name 2array
    swap dup first word? [ \ $instance add* ] when 2array ;

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

: ($see) ( word -- )
    [
        snippet-style get [
            code-style get [ see ] with-nesting
        ] with-style
    ] ($block) ;

: $see ( element -- ) first ($see) ;

: $definition ( element -- )
    "Definition" $heading $see ;

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

: $low-level-note
    drop
    "Calling this word directly is not necessary in most cases. Higher-level words call it automatically." $notes ;

: $values-x/y
    drop { { "x" number } { "y" number } } $values ;

: $io-error
    drop
    "Throws an error if the I/O operation fails." $errors ;

: $prettyprinting-note
    drop {
        "This word should only be called from inside the "
        { $link with-pprint } " combinator."
    } $notes ;

GENERIC: elements* ( elt-type element -- )

M: simple-element elements* [ elements* ] with each ;

M: object elements* 2drop ;

M: array elements*
    [ [ elements* ] with each ] 2keep
    [ first eq? ] keep swap [ , ] [ drop ] if ;

: elements ( elt-type element -- seq ) [ elements* ] { } make ;

: collect-elements ( element seq -- elements )
    [
        swap [
            elements [
                1 tail [ dup set ] each
            ] each
        ] curry each
    ] H{ } make-assoc keys ;
