! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel kernel-internals lists math strings
vectors ;

! This is loaded once everything else is available.
UNION: sequence array general-list string sbuf tuple vector ;

: (>list) ( n i seq -- list )
    pick pick <= [
        3drop [ ]
    ] [
        2dup nth >r >r 1 + r> (>list) r> swons
    ] ifte ;

M: object >list ( seq -- list ) dup length 0 rot (>list) ;
M: general-list >list ( list -- list ) ;

: seq-each ( seq quot -- )
    >r >list r> each ; inline

: seq-each-with ( obj seq quot -- )
    swap [ with ] seq-each 2drop ; inline

: length= ( seq seq -- ? ) length swap length number= ;

M: sequence = ( obj seq -- ? )
    2dup eq? [
        2drop t
    ] [
        over type over type eq? [
            2dup length= [
                swap >list swap >list =
            ] [
                2drop f
            ] ifte
        ] [
            2drop f
        ] ifte
    ] ifte ;
