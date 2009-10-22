! (c)2009 Joe Groff bsd license
USING: kernel sequences sequences.private math
combinators macros math.order math.ranges quotations fry effects
memoize.private generalizations ;
IN: sequences.generalizations

MACRO: nmin-length ( n -- )
    dup 1 - [ min ] n*quot
    '[ [ length ] _ napply @ ] ;

: nnth-unsafe ( n ...seq n -- )
    [ nth-unsafe ] swap [ apply-curry ] [ cleave* ] bi ; inline
MACRO: nset-nth-unsafe ( n -- )
    [ [ drop ] ]
    [ '[ [ set-nth-unsafe ] _ [ apply-curry ] [ cleave-curry ] [ spread* ] tri ] ]
    if-zero ;

: (neach) ( ...seq quot n -- len quot' )
    dup dup dup
    '[ [ _ nmin-length ] _ nkeep [ _ nnth-unsafe ] _ ncurry ] dip compose ; inline

: neach ( ...seq quot n -- )
    (neach) each-integer ; inline

: nmap-as ( ...seq quot exemplar n -- result )
    '[ _ (neach) ] dip map-integers ; inline

: nmap ( ...seq quot n -- result )
    dup '[ [ _ npick ] dip swap ] dip nmap-as ; inline

MACRO: nnew-sequence ( n -- )
    [ [ drop ] ]
    [ dup '[ [ new-sequence ] _ apply-curry _ cleave* ] ] if-zero ;

: nnew-like ( len ...exemplar quot n -- result... )
    5 dupn '[
        _ nover
        [ [ _ nnew-sequence ] dip call ]
        _ ndip [ like ]
        _ apply-curry
        _ spread*
    ] call ; inline

MACRO: (ncollect) ( n -- )
    3 dupn 1 +
    '[ [ [ keep ] _ ndip _ nset-nth-unsafe ] _ ncurry ] ;

: ncollect ( len quot ...into n -- )
    (ncollect) each-integer ; inline

: nmap-integers ( len quot ...exemplar n -- result... )
    4 dupn
    '[ [ over ] _ ndip [ [ _ ncollect ] _ nkeep ] _ nnew-like ] call ; inline

: mnmap-as ( m*seq quot n*exemplar m n -- result*n )
    dup '[ [ _ (neach) ] _ ndip _ nmap-integers ] call ; inline

: mnmap ( m*seq quot m n -- result*n )
    2dup '[ [ _ npick ] dip swap _ dupn ] 2dip mnmap-as ; inline

: naccumulator-for ( quot ...exemplar n -- quot' vec... )
    5 dupn '[
        [ [ length ] keep new-resizable ] _ napply
        [ [ [ push ] _ apply-curry _ spread* ] _ ncurry compose ] _ nkeep
    ] call ; inline

: naccumulator ( quot n -- quot' vec... )
    [ V{ } swap dupn ] keep naccumulator-for ; inline

: nproduce-as ( pred quot ...exemplar n -- seq... )
    7 dupn '[
        _ ndup
        [ _ naccumulator-for [ while ] _ ndip ]
        _ ncurry _ ndip
        [ like ] _ apply-curry _ spread*
    ] call ; inline

: nproduce ( pred quot n -- seq... )
    [ { } swap dupn ] keep nproduce-as ; inline
