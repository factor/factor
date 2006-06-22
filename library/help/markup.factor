! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables inspector io kernel namespaces
parser prettyprint sequences strings styles vectors words ;
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

M: simple-element print-element [ print-element ] each ;
M: string print-element [ write ] ($span) ;
M: array print-element unclip execute ;
M: word print-element { } swap execute ;

: print-element* ( element style -- )
    [ print-element ] with-style ;

: with-default-style ( quot -- )
    default-style [
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

: $snippet [ snippet-style print-element* ] ($span) ;

: $emphasis [ emphasis-style print-element* ] ($span) ;

: $url [ url-style print-element* ] ($span) ;

: $terpri terpri terpri drop ;

! Some blocks
: ($heading)
    last-element get [ terpri ] when ($block) ; inline

: $heading
    [ heading-style print-element* ] ($heading) ;

: ($code) ( presentation quot -- )
    [
        code-style [
            last-element off
            >r presented associate code-style hash-union r>
            with-nesting
        ] with-style
    ] ($block) ; inline

: $code ( content -- )
    "\n" join dup <input> [ write ] ($code) ;

: $vocabulary ( content -- )
    first word-vocabulary
    [ "Vocabulary" $heading $snippet ] when* ;

: $description ( content -- )
    "Description" $heading print-element ;

: $contract ( content -- )
    "Contract" $heading print-element ;

: $examples ( content -- )
    "Examples" $heading print-element ;

: $example ( content -- )
    1 swap cut* swap "\n" join dup <input> [
        input-style format terpri print-element
    ] ($code) ;

: $markup-example ( content -- )
    first dup unparse " print-element" append 1array $code
    print-element ;

: $warning ( content -- )
    [
        warning-style [
            last-element off
            "Warning" $heading print-element
        ] with-nesting
    ] ($heading) ;

! Some links
M: link article-title link-name article-title ;
M: link article-content link-name article-content ;
M: link summary "Link: " swap link-name append ;

: >link ( obj -- obj ) dup word? [ <link> ] unless ;

: ($subsection) ( quot object -- )
    subsection-style [
        [ swap curry ] keep dup article-title swap >link
        rot write-outliner
    ] with-style ;

: $link ( article -- )
    first link-style [
        dup article-title swap >link write-object
    ] with-style ;

: textual-list ( seq quot -- )
    [ ", " print-element ] interleave ; inline

: $links ( content -- )
    [ [ 1array $link ] textual-list ] ($span) ;

: $see-also ( content -- )
    "See also" $heading $links ;

: $where ( article -- )
    where dup empty? [
        drop
    ] [
        [
            where-style [
                "Parent topics: " write $links
            ] with-style
        ] ($block)
    ] if ;

: $table ( content -- )
    [
        table-style [
            H{ { table-gap { 5 5 0 } } }
            [ print-element ] tabular-output
        ] with-style
    ] ($block) table last-element set ;

: $values ( content -- )
    "Arguments and values" $heading
    [ unclip \ $snippet swap 2array swap 2array ] map $table ;

: $predicate ( content -- )
    { { "object" "an object" } } $values
    [
        "Tests if the object is an instance of the " ,
        { $link } swap append ,
        " class." ,
    ] { } make $description ;

: $list ( content -- ) [  "-" swap 2array ] map $table ;

: $errors ( content -- )
    "Errors" $heading print-element ;

: $side-effects ( content -- )
    "Side effects" $heading "Modifies " print-element
    [ $snippet ] textual-list ;

: $notes ( content -- )
    "Notes" $heading print-element ;

: ($see) ( word -- )
    code-style [ code-style [ see ] with-nesting ] with-style ;

: $see ( content -- ) first ($see) ;

: $definition ( content -- )
    "Definition" $heading ($see) ;

: $curious ( content -- )
    "For the curious..." $heading print-element ;

: $references ( content -- )
    "References" $heading
    unclip print-element [ \ $link swap 2array ] map $list ;

: $shuffle ( content -- )
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

: sort-articles ( seq -- assoc )
    [ [ article-title ] keep 2array ] map
    [ [ first ] 2apply <=> ] sort
    [ second ] map ;

: help-outliner ( seq quot -- | quot: obj -- )
    swap sort-articles [ ($subsection) terpri ] each-with ;
