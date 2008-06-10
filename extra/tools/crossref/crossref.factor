! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions assocs io kernel
math namespaces prettyprint sequences strings io.styles words
generic tools.completion quotations parser inspector
sorting hashtables vocabs parser source-files ;
IN: tools.crossref

: usage. ( word -- )
    smart-usage sorted-definitions. ;

: words-matching ( str -- seq )
    all-words [ dup word-name ] { } map>assoc completions ;

: apropos ( str -- )
    words-matching synopsis-alist reverse definitions. ;
