! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: tools
USING: arrays definitions assocs help tools io kernel
math namespaces prettyprint sequences strings styles words
generic completion quotations parser interpreter inspector ;

: definitions. ( seq -- )
    [ [ synopsis ] keep write-object nl ] each ;

: method-usage ( word generic -- methods )
    tuck methods
    [ second quot-uses key? ] subset-with
    0 <column>
    [ swap 2array ] map-with ;

: source-usage ( word -- pathnames )
    source-files get
    [ nip source-file-uses key? ]
    assoc-subset-with keys natural-sort ;

: smart-usage ( word -- definitions )
    [
        dup dup usage natural-sort
        dup [ generic? not ] subset %
        [ generic? ] subset [ method-usage % ] each-with
        source-usage [ <pathname> ] map %
    ] { } make ;

: usage. ( word -- ) smart-usage definitions. ;

: source-usage. ( word -- )
    smart-usage
    [ where ] map [ ] subset
    [ first <pathname> ] map
    prune natural-sort
    definitions. ;

: fix ( word -- )
    "Fixing " write dup pprint " and all usages..." print nl
    dup smart-usage swap add* [
        "Editing " write dup .
        "RETURN moves on to the next usage, C+d stops." print
        flush
        edit
        readln
    ] all? drop ;

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

: words-matching ( str -- seq )
    all-words [ dup word-name ] { } map>assoc completions ;

: apropos ( str -- ) words-matching definitions. ;
