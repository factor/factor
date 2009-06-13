! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays columns kernel math math.bits
math.order math.vectors sequences sequences.private fry ;
IN: math.matrices

! Matrices
: zero-matrix ( m n -- matrix )
    '[ _ 0 <array> ] replicate ;

: identity-matrix ( n -- matrix )
    #! Make a nxn identity matrix.
    dup [ [ = 1 0 ? ] with map ] curry map ;

! Matrix operations
: mneg ( m -- m ) [ vneg ] map ;

: n*m ( n m -- m ) [ n*v ] with map ;
: m*n ( m n -- m ) [ v*n ] curry map ;
: n/m ( n m -- m ) [ n/v ] with map ;
: m/n ( m n -- m ) [ v/n ] curry map ;

: m+   ( m m -- m ) [ v+ ] 2map ;
: m-   ( m m -- m ) [ v- ] 2map ;
: m*   ( m m -- m ) [ v* ] 2map ;
: m/   ( m m -- m ) [ v/ ] 2map ;

: v.m ( v m -- v ) flip [ v. ] with map ;
: m.v ( m v -- v ) [ v. ] curry map ;
: m.  ( m m -- m ) flip [ swap m.v ] curry map ;

: mmin ( m -- n ) [ 1/0. ] dip [ [ min ] each ] each ;
: mmax ( m -- n ) [ -1/0. ] dip [ [ max ] each ] each ;
: mnorm ( m -- n ) dup mmax abs m/n ;

<PRIVATE

: x ( seq -- elt ) first ; inline
: y ( seq -- elt ) second ; inline
: z ( seq -- elt ) third ; inline

: i ( seq1 seq2 -- n ) [ [ y ] [ z ] bi* * ] [ [ z ] [ y ] bi* * ] 2bi - ;
: j ( seq1 seq2 -- n ) [ [ z ] [ x ] bi* * ] [ [ x ] [ z ] bi* * ] 2bi - ;
: k ( seq1 seq2 -- n ) [ [ y ] [ x ] bi* * ] [ [ x ] [ y ] bi* * ] 2bi - ;

PRIVATE>

: cross ( vec1 vec2 -- vec3 ) [ i ] [ j ] [ k ] 2tri 3array ;

: proj ( v u -- w )
    [ [ v. ] [ norm-sq ] bi / ] keep n*v ;

: (gram-schmidt) ( v seq -- newseq )
    [ dupd proj v- ] each ;

: gram-schmidt ( seq -- orthogonal )
    V{ } clone [ over (gram-schmidt) over push ] reduce ;

: norm-gram-schmidt ( seq -- orthonormal )
    gram-schmidt [ normalize ] map ;

: cross-zip ( seq1 seq2 -- seq1xseq2 )
    [ [ 2array ] with map ] curry map ;
    
: m^n ( m n -- n ) 
    make-bits over first length identity-matrix
    [ [ dupd m. ] when [ dup m. ] dip ] reduce nip ;
