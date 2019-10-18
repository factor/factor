! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences-internals
USING: arrays generic kernel math sequences ;

: midpoint [ midpoint@ ] keep nth-unsafe ; inline

: partition ( seq -1/1 -- seq )
    >r dup midpoint@ r> 1 < [ head-slice ] [ tail-slice ] if ;
    inline

: (binsearch) ( elt quot seq -- elt quot i )
    dup length 1 <= [
        slice-from
    ] [
        [ midpoint swap call ] 3keep roll dup zero?
        [ drop dup slice-from swap midpoint@ + ]
        [ partition (binsearch) ] if
    ] if ; inline

: flatten-slice ( seq -- slice )
    #! Binsearch returns an index relative to the sequence
    #! being sliced, so if we are given a slice as input,
    #! unexpected behavior will result.
    dup slice? [ >array ] when 0 over length rot <slice> ;
    inline

IN: sequences

: binsearch ( elt seq quot -- i )
    swap dup empty?
    [ 3drop f ] [ flatten-slice (binsearch) 2nip ] if ; inline

: binsearch* ( elt seq quot -- result )
    over >r binsearch [ r> ?nth ] [ r> drop f ] if* ; inline
