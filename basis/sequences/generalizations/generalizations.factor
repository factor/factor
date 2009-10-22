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
    dup dup dup dup '[
        _ nover
        [ [ _ nnew-sequence ] dip call ]
        _ ndip [ like ]
        _ apply-curry
        _ spread*
    ] call ; inline

MACRO: (ncollect) ( n -- )
    dup dup 1 +
    '[ [ [ keep ] _ ndip _ nset-nth-unsafe ] _ ncurry ] ;

: ncollect ( len quot ...into n -- )
    (ncollect) each-integer ; inline

: nmap-integers ( len quot ...exemplar n -- result... )
    dup dup dup
    '[ [ over ] _ ndip [ [ _ ncollect ] _ nkeep ] _ nnew-like ] call ; inline

: mnmap-as ( m*seq quot n*exemplar m n -- result*n )
    dup '[ [ _ (neach) ] _ ndip _ nmap-integers ] call ; inline

: mnmap ( m*seq quot m n -- result*n )
    2dup '[ [ _ npick ] dip swap _ dupn ] 2dip mnmap-as ; inline

