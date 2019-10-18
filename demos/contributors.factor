! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
REQUIRES: libs/process libs/xml ;
USING: memory io process sequences prettyprint kernel arrays
xml xml-utils ;
IN: contributors

: changelog ( -- xml )
    image parent-dir cd
    "darcs changes --xml-output" "r" <process-stream> read-xml ;

: authors ( xml -- seq )
    children-tags [ "author" tag-attr ] map ;

: patch-count ( authors author -- n )
    swap [ = ] subset-with length ;

: patch-counts ( authors -- assoc )
    dup prune [ [ patch-count ] keep 2array ] map-with ;

: contributors ( -- )
    changelog authors patch-counts sort-keys reverse . ;

PROVIDE: demos/contributors ;

MAIN: demos/contributors contributors ;
