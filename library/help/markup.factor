! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays generic hashtables io kernel lists namespaces
parser prettyprint sequences strings styles vectors words ;

: uncons* dup first swap 1 swap tail ;

: unswons* uncons* swap ;

! Simple markup language.

! <element> ::== <string> | <simple-element> | <fancy-element>
! <simple-element> ::== { <element>* }
! <fancy-element> ::== { <type> <element> }

! Element types are words whose name begins with $.

PREDICATE: array simple-element
    dup empty? [ drop t ] [ first word? not ] if ;

M: string print-element last-block off format* ;

M: array print-element unswons* execute ;

M: word print-element { } swap execute ;

: ($span) ( content style -- )
    last-block off [ print-element ] with-style ;

: ($block) ( quot -- )
    last-block [ [ terpri ] unless t ] change
    call
    terpri
    last-block on ; inline

! Some spans

: $heading heading-style ($span) terpri terpri ;

: $subheading [ subheading-style ($span) ] ($block) ;

: $snippet snippet-style ($span) ;

: $emphasis emphasis-style ($span) ;

: $url url-style ($span) ;

: $terpri last-block off terpri terpri drop ;

! Some blocks
M: simple-element print-element
    [ print-element ] each ;

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
        "Syntax" $subheading
        >r word-name $snippet " " $snippet r> $snippet
    ] [
        drop
    ] if* ;

: $stack-effect ( word -- )
    stack-effect [
        "Stack effect" $subheading $snippet
    ] when* ;

: $vocabulary ( content -- )
    "Vocabulary" $subheading $snippet ;

: $synopsis ( content -- )
    first dup
    word-vocabulary [ $vocabulary ] when*
    dup parsing? [ $syntax ] [ $stack-effect ] if ;

: $description ( content -- )
    "Description" $subheading print-element ;

: $contract ( content -- )
    "Contract" $subheading print-element ;

: $examples ( content -- )
    "Examples" $subheading print-element ;

: $warning ( content -- )
    [
        current-style warning-style hash-union [
            "Warning" $subheading print-element
        ] with-nesting
    ] ($block) ;

: textual-list ( seq quot -- )
    [ ", " print-element ] interleave ; inline

: $see ( content -- )
    code-style [ first see ] with-nesting* ;

: $example ( content -- )
    first2 swap dup <input> [
        input-style [ format* ] with-style terpri format*
    ] ($code) ;

! Some links
TUPLE: link name ;

M: link article-title link-name article-title ;

M: link article-content link-name article-content ;

DEFER: help

: ($subsection) ( quot object -- )
    subsection-style [
        [ swap curry ] keep dup article-title swap <link>
        rot simple-outliner
    ] with-style ;

: $subsection ( object -- )
    [ first [ (help) ] swap ($subsection) ] ($block) ;

: >link ( obj -- obj ) dup string? [ <link> ] when ;

: $link ( article -- )
    last-block off first dup word? [
        pprint
    ] [
        link-style [
            dup article-title swap >link simple-object
        ] with-style
    ] if ;

: $definition ( content -- )
    "Definition" $subheading $see ;

: $see-also ( content -- )
    "See also" $subheading [ 1array $link ] textual-list ;

: $values ( content -- )
    "Arguments and values" $subheading
    [ unswons* $snippet " -- " format* print-element ]
    [ terpri ] interleave ;

: $predicate ( content -- )
    { { "object" "an object" } } $values
    [
        "Tests if the object is an instance of the " ,
        { $link } swap append ,
        " class." ,
    ] { } make $description ;

: $list ( content -- )
    [
        [
            list-element-style [ print-element ] with-nesting*
        ] ($block)
    ] each ;

: $errors ( content -- )
    "Errors" $subheading print-element ;

: $side-effects ( content -- )
    "Side effects" $subheading "Modifies " print-element
    [ $snippet ] textual-list ;

: $notes ( content -- )
    "Notes" $subheading print-element ;

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
