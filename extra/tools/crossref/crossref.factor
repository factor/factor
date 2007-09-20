! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions assocs io kernel
math namespaces prettyprint sequences strings io.styles words
generic tools.completion quotations parser inspector
sorting hashtables vocabs ;
IN: tools.crossref

: synopsis-alist ( definitions -- alist )
    [ dup synopsis swap ] { } map>assoc ;

: definitions. ( alist -- )
    [ write-object nl ] assoc-each ;

: (method-usage) ( word generic -- methods )
    tuck methods
    [ second quot-uses key? ] curry* subset
    0 <column>
    swap [ 2array ] curry map ;

: method-usage ( word seq -- methods )
    [ generic? ] subset [ (method-usage) ] curry* map concat ;

: compound-usage ( words -- seq )
    [ generic? not ] subset ;

: smart-usage ( word -- definitions )
    \ f or
    dup usage dup compound-usage -rot method-usage append ;

: usage. ( word -- )
    smart-usage synopsis-alist sort-keys definitions. ;

: words-matching ( str -- seq )
    all-words [ dup word-name ] { } map>assoc completions ;

: apropos ( str -- )
    words-matching synopsis-alist reverse definitions. ;
