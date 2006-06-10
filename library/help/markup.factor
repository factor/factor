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
M: string print-element last-block off format* ;
M: array print-element unclip execute ;
M: word print-element { } swap execute ;

: ($span) ( content style -- )
    last-block off [ print-element ] with-style ;

: ($block) ( quot -- )
    last-block [ [ terpri ] unless t ] change
    call
    terpri
    last-block on ; inline

! Some spans

: $heading [ heading-style ($span) ] ($block) ;

: $snippet snippet-style ($span) ;

: $emphasis emphasis-style ($span) ;

: $url url-style ($span) ;

: $terpri last-block off terpri terpri drop ;

! Some blocks

: ($code) ( presentation quot -- )
    [
        code-style [
            >r current-style swap presented pick set-hash r>
            with-nesting
        ] with-style
    ] ($block) ; inline

: $code ( content -- )
    "\n" join dup <input> [ format* ] ($code) ;

: $syntax ( word -- )
    dup stack-effect [
        "Syntax" $heading
        >r word-name $snippet " " $snippet r> $snippet
    ] [
        drop
    ] if* ;

: $stack-effect ( word -- )
    stack-effect [
        "Stack effect" $heading $snippet
    ] when* ;

: $vocabulary ( content -- )
    first word-vocabulary [
        "Vocabulary" $heading $snippet
    ] when* ;

: $synopsis ( content -- )
    dup $vocabulary
    first dup parsing? [ $syntax ] [ $stack-effect ] if ;

: $description ( content -- )
    "Description" $heading print-element ;

: $contract ( content -- )
    "Contract" $heading print-element ;

: $examples ( content -- )
    "Examples" $heading print-element ;

: $warning ( content -- )
    [
        current-style warning-style hash-union [
            "Warning" $heading print-element
        ] with-nesting
    ] ($block) ;

: textual-list ( seq quot -- )
    [ ", " print-element ] interleave ; inline

: $see ( content -- )
    code-style [ first see ] with-nesting* ;

: $example ( content -- )
    1 swap cut* swap "\n" join dup <input> [
        input-style [ format* ] with-style terpri print-element
    ] ($code) ;

! Some links
TUPLE: link name ;

M: link article-title link-name article-title ;
M: link article-content link-name article-content ;
M: link summary "Link to " swap link-name unparse append ;

GENERIC: >link
M: object >link ;
M: string >link <link> ;
M: f >link <link> ;

: ($subsection) ( quot object -- )
    subsection-style [
        [ swap curry ] keep dup article-title swap >link
        rot simple-outliner
    ] with-style ;

: $subsection ( object -- )
    [
        first [ help ] swap ($subsection)
    ] ($block) ;

: ($subtopic) ( element -- quot )
    [
        default-style
        [ last-block on print-element ] with-nesting*
    ] curry ;

: $subtopic ( object -- )
    [
        unclip swap ($subtopic) [
            subtopic-style [ print-element ] with-style
        ] write-outliner
    ] ($block) ;

: $link ( article -- )
    last-block off first dup word? [
        pprint
    ] [
        link-style [
            dup article-title swap >link simple-object
        ] with-style
    ] if ;

: $definition ( content -- )
    "Definition" $heading $see ;

: $links ( content -- )
    [ 1array $link ] textual-list ;

: $see-also ( content -- )
    "See also" $heading $links ;

: $table ( content -- )
    [ [ print-element ] tabular-output ] ($block) ;

: $values ( content -- )
    "Arguments and values" $heading
    [ first2 >r \ $snippet swap 2array r> 2array ] map
    $table ;

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
    "Calling this word directly is not necessary in most cases. Higher-level words call it automatically." print-element ;

: $values-x/y
    drop
    { { "x" "a complex number" } { "y" "a complex number" } } $values ;

: $io-error
    drop
    "Throws an error if the I/O operation fails." $errors ;
