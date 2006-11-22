! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic hashtables io kernel
namespaces parser prettyprint sequences strings styles vectors
words ;
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
    last-block? [ terpri ] when
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
    last-element off
    [ print-element ] with-default-style ;

: ($block) ( quot -- )
    last-element get { f table } member? [ terpri ] unless
    span last-element set
    call
    block last-element set ; inline

! Some spans

: $snippet [ snippet-style get print-element* ] ($span) ;

: $emphasis [ emphasis-style get print-element* ] ($span) ;

: $strong [ strong-style get print-element* ] ($span) ;

: $url [ url-style get print-element* ] ($span) ;

: $terpri terpri terpri drop ;

! Some blocks
: ($heading)
    last-element get [ terpri ] when ($block) ; inline

: $heading ( element -- )
    [ heading-style get print-element* ] ($heading) ;

: ($code) ( presentation quot -- )
    [
        code-style get [
            last-element off
            >r presented associate code-style get hash-union r>
            with-nesting
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
        input-style get format terpri print-element
    ] ($code) ;

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

: ($link) ( article -- )
    link-style get [
        dup article-title swap >link write-object
    ] with-style ;

: $link ( element -- )
    first ($link) ;

: $vocab-link ( element -- )
    first link-style get [
        dup <vocab-link> write-object
    ] with-style ;

: $vocabulary ( element -- )
    [ word-vocabulary ] map
    [ "Vocabulary" $heading terpri $vocab-link ] when* ;

: textual-list ( seq quot -- )
    [ ", " print-element ] interleave ; inline

: $links ( topics -- )
    [ [ 1array $link ] textual-list ] ($span) ;

: $see-also ( topics -- )
    "See also" $heading $links ;

: $doc-path ( article -- )
    doc-path dup empty? [
        drop
    ] [
        [
            doc-path-style get [
                "Parent topics: " write $links
            ] with-style
        ] ($block)
    ] if ;

: $grid ( content style -- )
    [
        table-content-style get [
            [ last-element off print-element ] tabular-output
        ] with-style
    ] ($block) table last-element set ;

: $list ( element -- )
    [ bullet get swap 2array ] map list-style get $grid ;

: $table ( element -- )
    table-style get $grid ;

: $values ( element -- )
    "Inputs and outputs" $heading
    [ unclip \ $snippet swap 2array swap 2array ] map $table ;

: $predicate ( element -- )
    { { "object" "an object" } } $values
    [
        "Tests if the object is an instance of the " ,
        { $link } swap append ,
        " class." ,
    ] { } make $description ;

: $errors ( element -- )
    "Errors" $heading print-element ;

: $side-effects ( element -- )
    "Side effects" $heading "Modifies " print-element
    [ $snippet ] textual-list ;

: $notes ( element -- )
    "Notes" $heading print-element ;

: ($see) ( word -- )
    [
        code-style get [
            code-style get [ see ] with-nesting
        ] with-style
    ] ($block) ;

: $see ( element -- ) first ($see) ;

: $definition ( word -- )
    "Definition" $heading ($see) ;

: $curious ( element -- )
    "For the curious..." $heading print-element ;

: $references ( element -- )
    "References" $heading
    unclip print-element [ \ $link swap 2array ] map $list ;

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

: sort-articles ( seq -- newseq )
    [ [ article-title ] keep 2array ] map
    [ [ first ] 2apply <=> ] sort
    1 <column> ;
