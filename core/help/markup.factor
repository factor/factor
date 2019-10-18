! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic io kernel assocs hashtables
namespaces parser prettyprint sequences strings styles vectors
words modules ;
IN: help

! Simple markup language.

! <element> ::== <string> | <simple-element> | <fancy-element>
! <simple-element> ::== { <element>* }
! <fancy-element> ::== { <type> <element> }

! Element types are words whose name begins with $.

PREDICATE: array simple-element
    dup empty? [ drop t ] [ first word? not ] if ;

M: simple-element elements* [ elements* ] each-with ;

M: object elements* 2drop ;

M: array elements*
    [ [ elements* ] each-with ] 2keep
    [ first eq? ] keep swap [ , ] [ drop ] if ;

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
    default-style get [
        last-element off
        H{ } swap with-nesting
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
    1 swap cut* swap "\n" join dup <input> [
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
: >link ( obj -- obj ) dup link? [ <link> ] unless ;

: write-link ( string object -- )
    link-style get [ write-object ] with-style ;

: ($link) ( article -- )
    dup article-name swap >link write-link
    span last-element set ;

: $link ( element -- )
    first ($link) ;

: $vocab-link ( element -- )
    first dup <vocab-link> write-link ;

: $module-link ( element -- )
    first dup <module-link> write-link ;

: $vocabulary ( element -- )
    [ word-vocabulary ] map
    [ "Vocabulary" $heading nl $vocab-link ] when* ;

: textual-list ( seq quot -- )
    [ ", " print-element ] swap interleave ; inline

: $links ( topics -- )
    [ [ ($link) ] textual-list ] ($span) ;

: $see-also ( topics -- )
    "See also" $heading $links ;

: $related ( element -- )
    first dup "related" word-prop remove dup empty?
    [ drop ] [ $see-also ] if ;

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

: $instance ( element -- )
    first dup word-name a/an write bl ($link) ;

: values-row ( seq -- seq )
    unclip \ $snippet swap 2array
    swap dup first word? [ \ $instance add* ] when 2array ;

: $values ( element -- )
    "Inputs and outputs" $heading
    [ values-row ] map $table ;

: $side-effects ( element -- )
    "Side effects" $heading "Modifies " print-element
    [ $snippet ] textual-list ;

: $predicate ( element -- )
    { { "object" "an object" } { "?" "a boolean" } } $values
    [
        "Tests if the object is an instance of the " ,
        first "predicating" word-prop \ $link swap 2array ,
        " class." ,
    ] { } make $description ;

: reader-slot-spec ( reader -- slot-spec class )
    dup "reading" word-prop [ slot-of-reader ] keep ;

: $reader-values ( slot-spec class -- )
    [
        dup word-name swap 2array ,
        dup slot-spec-name swap slot-spec-decl 2array ,
    ] { } make $values ;

: $reader-description ( slot-spec class -- )
    "Outputs the value stored in the " print-element
    swap slot-spec-name $snippet
    " slot of a " print-element
    ($link)
    " instance." print-element ;

: $reader ( element -- )
    first reader-slot-spec 2dup
    $reader-values
    $reader-description ;

: writer-slot-spec ( reader -- slot-spec class )
    dup "writing" word-prop [ slot-of-writer ] keep ;

: $writer-values ( slot-spec class -- )
    swap [
        dup slot-spec-name swap slot-spec-decl 2array ,
        dup word-name swap 2array ,
    ] { } make $values ;

: $writer-description ( slot-spec class -- )
    "Stores a value to the " print-element
    swap slot-spec-name $snippet
    " slot of a " print-element
    ($link)
    " instance." print-element ;

: $writer ( element -- )
    first writer-slot-spec
    2dup $writer-values
    2dup $writer-description
    nip word-name 1array $side-effects ;

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

: $definition ( word -- )
    "Definition" $heading $see ;

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
    drop
    { { "x" "a complex number" } { "y" "a complex number" } } $values ;

: $io-error
    drop
    "Throws an error if the I/O operation fails." $errors ;

: $prettyprinting-note
    drop {
        "This word should only be called from inside the "
        { $link with-pprint } " combinator."
    } $notes ;

: sort-articles ( seq -- newseq )
    [ dup article-title ] { } map>assoc sort-values 0 <column> ;
