! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays generic hashtables inspector io kernel namespaces
parser prettyprint sequences strings styles vectors words ;

! Simple markup language.

! <element> ::== <string> | <simple-element> | <fancy-element>
! <simple-element> ::== { <element>* }
! <fancy-element> ::== { <type> <element> }

! Element types are words whose name begins with $.

PREDICATE: array simple-element
    dup empty? [ drop t ] [ first word? not ] if ;

M: simple-element print-element [ print-element ] each ;
M: string print-element last-block off write ;
M: array print-element unclip execute ;
M: word print-element { } swap execute ;

: ($span) ( content style -- )
    last-block off [ print-element ] with-style ;

: ?terpri ( -- )
    last-block [ [ terpri ] unless t ] change ;

: ($block) ( quot -- )
    ?terpri
    call
    terpri
    last-block on ; inline

! Some spans

: $snippet snippet-style ($span) ;

: $emphasis emphasis-style ($span) ;

: $url url-style ($span) ;

: $terpri last-block off terpri terpri drop ;

! Some blocks
: $title [ title-style ($span) ] ($block) ;

: $heading [ heading-style ($span) ] ($block) ;

: ($code) ( presentation quot -- )
    [
        code-style [
            >r presented associate r> with-nesting
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
            "Warning" $heading print-element
        ] with-nesting
    ] ($block) ;

! Some links
TUPLE: link name ;

M: link article-title link-name article-title ;
M: link article-content link-name article-content ;
M: link summary "Link: " swap link-name append ;

: ($subsection) ( quot object -- )
    subsection-style [
        [ swap curry ] keep dup article-title swap <link>
        rot write-outliner
    ] with-style ;

: >link ( obj -- obj ) dup word? [ <link> ] unless ;

: $link ( article -- )
    last-block off first link-style
    [ dup article-title swap >link write-object ] with-style ;

: textual-list ( seq quot -- )
    [ ", " print-element ] interleave ; inline

: $links ( content -- )
    [ 1array $link ] textual-list ;

: $where ( article -- )
    where dup empty? [
        drop
    ] [
        where-style [
            [ "Parent topics: " write $links ] ($block)
        ] with-style
    ] if ;

: $see-also ( content -- )
    "See also" $heading $links ;

: $table ( content -- )
    ?terpri table-style [
        H{ } [ print-element ] tabular-output
    ] with-style ;

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

: $see ( content -- )
    code-style [ dup array? [ first ] when see ] with-nesting ;

: $definition ( content -- )
    "Definition" $heading $see ;

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
