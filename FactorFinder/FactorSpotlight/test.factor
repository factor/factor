! Copyright (C) 2011 PolyMicro Systems
! See http://factorcode.org/license.txt for BSD license.
! Version: 1.0
! DRI: Dave Carlton
! Description: Defintions for personal use

USING: accessors alien alien.accessors assocs io kernel math
math.parser namespaces prettyprint sequences strings.parser
vocabs.parser ;

IN: vocabs
: current-vocab-str ( -- str )
    current-vocab name>> ;

: vwords ( -- )
    current-vocab-str vocab-words keys [ pprint " " print ] each ;

IN: prettyprint.config
: hex ( -- )
    16 number-base set ;

: decimal ( -- )
    10 number-base set ;

: octal ( -- )
    8 number-base set ;

: binary ( -- )
    2 number-base set ;

IN: syntax
SYNTAX: ." parse-string write ;

IN: davec
: dm ( adr count -- )
    [ dup alien-address >hex write " " write
      16 [ dup 1 alien-unsigned-1  >hex write " " write
             alien-address 1 + <alien> ] times
      "" print
    ] times
    drop ;
