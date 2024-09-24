! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators generalizations kernel math math.order
memoize.private quotations sequences sequences.private ;
IN: sequences.generalizations

MACRO: (nsequence) ( n -- quot )
    <iota> reverse [ '[ [ _ swap set-nth-unsafe ] keep ] ] map concat ;

MACRO: nsequence ( n exemplar -- quot )
    [ [nsequence] ] keep '[ @ _ like ] ;

MACRO: narray ( n -- quot )
    '[ _ { } nsequence ] ;

MACRO: firstn-unsafe ( n -- quot )
    [firstn] ;

MACRO: firstn ( n -- quot )
    [ [ drop ] ] [
        [ 1 - swap bounds-check 2drop ]
        [ firstn-unsafe ]
        bi-curry '[ _ _ bi ]
    ] if-zero ;

MACRO: set-firstn-unsafe ( n -- quot )
    [ 1 + ]
    [ <iota> [ '[ _ rot [ set-nth-unsafe ] keep ] ] map ] bi
    '[ _ -nrot _ spread drop ] ;

MACRO: set-firstn ( n -- quot )
    [ [ drop ] ] [
        [ 1 - swap bounds-check 2drop ]
        [ set-firstn-unsafe ]
        bi-curry '[ _ _ bi ]
    ] if-zero ;

MACRO: ?firstn ( n -- quot )
    dup '[
        _ over length [-]
        [ f <repetition> ] [ _ over - swap ] bi
        [ firstn-unsafe ] bi-curry@ bi*
    ] ;

: lastn ( seq n -- elts... )
    [ tail-slice* ] [ firstn-unsafe ] bi ; inline

MACRO: ?lastn ( n -- quot )
    dup '[
        _ over length [-]
        [ f <repetition> swap ]
        [ _ over - swapd [ tail-slice* ] keep ] bi
        [ firstn-unsafe ] 2bi@
    ] ;

: set-lastn ( elts... seq n -- )
    [ tail-slice* ] [ set-firstn-unsafe ] bi ; inline

: nappend ( n -- seq ) narray concat ; inline

: nappend-as ( n exemplar -- seq )
    [ narray ] [ concat-as ] bi* ; inline

MACRO: nmin-length ( n -- quot )
    dup 1 - [ min ] n*quot
    '[ [ length ] _ napply @ ] ;

: nnth ( n seq... n -- )
    [ nth ] swap [ apply-curry ] [ cleave* ] bi ; inline

: nnth-unsafe ( n seq... n -- )
    [ nth-unsafe ] swap [ apply-curry ] [ cleave* ] bi ; inline

MACRO: nset-nth-unsafe ( n -- quot )
    [ [ drop ] ]
    [ '[ [ set-nth-unsafe ] _ [ apply-curry ] [ cleave-curry ] [ spread* ] tri ] ]
    if-zero ;

: (neach) ( seq... quot n -- len quot' )
    dup dup dup
    '[ [ _ nmin-length ] _ nkeep [ _ nnth-unsafe ] _ ncurry ] dip compose ; inline

: neach ( seq... quot n -- )
    (neach) each-integer ; inline

: nmap-as ( seq... quot exemplar n -- result )
    '[ _ (neach) ] dip map-integers-as ; inline

: nmap ( seq... quot n -- result )
    dup '[ [ _ npick ] dip swap ] dip nmap-as ; inline

MACRO: nnew-sequence ( n -- quot )
    [ [ drop ] ]
    [ dup '[ [ new-sequence ] _ apply-curry _ cleave* ] ] if-zero ;

: nnew-like ( len exemplar... quot n -- result... )
    5 dupn '[
        _ nover
        [ [ _ nnew-sequence ] dip call ]
        _ ndip [ like ]
        _ apply-curry
        _ spread*
    ] call ; inline

MACRO: (ncollect) ( n -- quot )
    3 dupn 1 +
    '[ [ [ keep ] _ ndip _ nset-nth-unsafe ] _ ncurry ] ;

: ncollect ( len quot into... n -- )
    (ncollect) each-integer ; inline

: nmap-integers-as ( len quot exemplar... n -- result... )
    4 dupn
    '[ [ over ] _ ndip [ [ _ ncollect ] _ nkeep ] _ nnew-like ] call ; inline

: mnmap-as ( m*seq quot n*exemplar m n -- result*n )
    dup '[ [ _ (neach) ] _ ndip _ nmap-integers-as ] call ; inline

: mnmap ( m*seq quot m n -- result*n )
    2dup '[ [ _ npick ] dip swap _ dupn ] 2dip mnmap-as ; inline

: ncollector-as ( quot exemplar... n -- quot' vec... )
    5 dupn '[
        [ [ length ] keep new-resizable ] _ napply
        [ [ [ push ] _ apply-curry _ spread* ] _ ncurry compose ] _ nkeep
    ] call ; inline

: ncollector ( quot n -- quot' vec... )
    [ V{ } swap dupn ] keep ncollector-as ; inline

: nproduce-as ( pred quot exemplar... n -- seq... )
    7 dupn '[
        _ ndup
        [ _ ncollector-as [ while ] _ ndip ]
        _ ncurry _ ndip
        [ like ] _ apply-curry _ spread*
    ] call ; inline

: nproduce ( pred quot n -- seq... )
    [ { } swap dupn ] keep nproduce-as ; inline

MACRO: nmap-reduce ( map-quot reduce-quot n -- quot )
    -rot dupd compose overd over '[
        [ [ first ] _ napply @ 1 ] _ nkeep
        _ _ (neach) each-integer-from
    ] ;

: nall? ( seqs... quot n -- ? )
    (neach) all-integers? ; inline

MACRO: finish-nfind ( n -- quot )
    [ 1 + ] keep dup dup dup f <array> >quotation '[
        _ npick
        [ [ dup ] _ ndip _ nnth-unsafe ]
        [ _ ndrop @ ]
        if
    ] ;

: (nfind) ( seqs... quot n quot' -- i elts... )
    over
    [ '[ _ _ (neach) @ ] ] dip
    [ '[ _ finish-nfind ] ] keep
    nbi ; inline

: nfind ( seqs... quot n -- i elts... )
    [ find-integer ] (nfind) ; inline

: nany? ( seqs... quot n -- ? )
    [ nfind ] [ ndrop ] bi >boolean ; inline
