! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
USING: arrays gadgets gadgets-panes gadgets-presentations
hashtables inspector io kernel lists namespaces prettyprint
sequences strings styles words ;

: uncons* dup first swap 1 swap tail ;

: unswons* uncons* swap ;

! Simple markup language.

! <element> ::== <string> | <simple-element> | <fancy-element>
! <simple-element> ::== { <element>* }
! <fancy-element> ::== { <type> <element> }

! Element types are words whose name begins with $.

PREDICATE: array simple-element
    dup empty? [ drop t ] [ first word? not ] if ;

: write-term ( string -- )
    dup terms get hash [
        dup <term> presented associate [ format* ] with-style
    ] [
        format*
    ] if ;

M: string print-element
    " " split [ write-term ] [ bl ] interleave ;

M: array print-element
    unswons* execute ;

M: word print-element
    { } swap execute ;

: ($span) ( content style -- )
    [ print-element ] with-style ;

: ($block) ( content style -- )
    terpri*
    [ [ print-element ] with-nesting* ] with-style
    terpri* ;

! Some spans

: $heading heading-style ($block) ;

: $subheading subheading-style ($block) ;

: $snippet snippet-style ($span) ;

: $emphasis emphasis-style ($span) ;

: $url url-style ($span) ;

: $terpri terpri drop ;

! Some blocks
M: simple-element print-element
    current-style [ [ print-element ] each ] with-nesting ;

: ($code) ( text presentation -- )
    terpri*
    code-style [
        current-style swap presented pick set-hash
        [ format* ] with-nesting
    ] with-style
    terpri* ;

: $code ( content -- )
    first dup <input> ($code) ;

: $example ( content -- )
    terpri*
    code-style [
        current-style over <input> presented pick set-hash
        [ . ] with-nesting
    ] with-style
    terpri* ;

: $synopsis ( content -- )
    "Synopsis" $subheading  first [ synopsis ] keep ($code) ;

: $values ( content -- )
    "Arguments and values" $subheading [
        unswons* $emphasis " -- " format* print-element terpri*
    ] each ;

: $description ( content -- )
    "Description" $subheading print-element ;

: $contract ( content -- )
    "Contract" $subheading print-element ;

: $examples ( content -- )
    "Examples" $subheading [ $example ] each ;

: $see-also ( content -- )
    "See also" $subheading [ pprint bl ] each ;

: $see ( content -- )
    code-style [ [ first see ] with-nesting* ] with-style ;

: $definition ( content -- )
    "Definition" $subheading $see ;

: $predicate ( content -- )
    { { "object" "an object" } } $values
    "Tests if the top of the stack is a " swap first "." append3
    1array $description ;

: $list ( content -- )
    terpri* [ "- " format* print-element terpri* ] each ;

: $safety ( content -- )
    "Memory safety" $subheading print-element ;

! Some links
TUPLE: link name ;

M: link article-title link-name article-title ;

M: link article-content link-name article-content ;

M: link summary ( term -- string )
    "An article named \"" swap article-title "\"" append3 ;

DEFER: help

: ($link) dup article-title swap ;

: $subsection ( object -- )
    terpri*
    subheading-style [
        first <link> ($link) dup [ link-name (help) ] curry
        simple-outliner
    ] with-style ;

: $link ( article -- ) first <link> ($link) simple-object ;

: $glossary ( element -- ) first <term> ($link) simple-object ;
