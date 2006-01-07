! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
USING: arrays
generic hashtables inspector io kernel lists namespaces parser
prettyprint sequences strings styles vectors words ;

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
M: simple-element print-element [ print-element ] each ;

: ($code) ( presentation quot -- )
    terpri* 
    code-style [
        >r current-style swap presented pick set-hash r>
        with-nesting
    ] with-style
    terpri* ; inline

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
    stack-effect [ "Stack effect" $subheading $snippet ] when* ;

: $synopsis ( content -- )
    first dup
    word-vocabulary [ "Vocabulary" $subheading $snippet ] when*
    dup parsing? [ $syntax ] [ $stack-effect ] if
    terpri* ;

: $description ( content -- )
    "Description" $subheading print-element ;

: $contract ( content -- )
    "Contract" $subheading print-element ;

: $examples ( content -- )
    "Examples" $subheading print-element ;

: $warning ( content -- )
    terpri*
    current-style warning-style hash-union [
        "Warning" $subheading print-element
    ] with-nesting
    terpri* ;

: textual-list ( seq quot -- )
    [ "," format* bl ] interleave ; inline

: $see-methods
    "Methods defined in the generic word:" format* terpri
    [ order word-sort ] keep
    [ "methods" word-prop hash . ] curry
    sequence-outliner ;

: $see-implementors
    "Generic words defined for this class:" format* terpri
    [ implementors word-sort ] keep
    [ swap "methods" word-prop hash . ] curry
    sequence-outliner ;

: ($see)
    terpri*
    code-style [ with-nesting* ] with-style
    terpri* ;

: $see ( content -- )
    first {
        { [ dup class? ] [ $see-implementors ] }
        { [ dup generic? ] [ $see-methods ] }
        { [ t ] [ [ see ] ($see) ] }
    } cond ;

: $example ( content -- )
    first2 swap dup <input>
    [
        input-style [ format* ] with-style terpri format*
    ] ($code) ;

! Some links
TUPLE: link name ;

M: link article-title link-name article-title ;

M: link article-name link-name article-name ;

M: link article-content link-name article-content ;

M: link summary ( term -- string )
    "An article named \"" swap article-title "\"" append3 ;

DEFER: help

: $subsection ( object -- )
    terpri*
    subsection-style [
        first dup article-title swap <link>
        dup [ link-name (help) ] curry
        simple-outliner
    ] with-style ;

: $link ( article -- )
    first dup article-name swap <link> simple-object ;

: $glossary ( element -- )
    first dup <term> simple-object ;

: $definition ( content -- )
    "Definition" $subheading $see ;

: $see-also ( content -- )
    "See also" $subheading [ 1array $link ] textual-list ;

: $values ( content -- )
    "Arguments and values" $subheading [
        unswons* $snippet " -- " format* print-element
    ] [
        terpri
    ] interleave ;

: $predicate ( content -- :r)
    { { "object" object } } $values
    "Tests if the top of the stack is " $description
    dup word-name a/an print-element $link "." print-element ;

: $list ( content -- )
    terpri* [ "- " format* print-element terpri* ] each ;

: $safety ( content -- )
    "Memory safety" $subheading print-element ;

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
