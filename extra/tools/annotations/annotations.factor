! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words parser io inspector quotations sequences
prettyprint tools.interpreter ;
IN: tools.annotations

: annotate ( word quot -- )
    over >r >r word-def r> call r>
    swap define-compound do-parse-hook ;
    inline

: entering ( str -- ) "! Entering: " write print .s flush ;

: leaving ( str -- ) "! Leaving: " write print .s flush ;

: (watch) ( str def -- def )
    over [ entering ] curry
    rot [ leaving ] curry
    swapd 3append ;

: watch ( word -- )
    dup word-name swap [ (watch) ] annotate ;

: breakpoint ( word -- )
    [ \ break add* ] annotate ;

: breakpoint-if ( quot word -- )
    [ [ [ break ] when ] swap 3append ] annotate ;
