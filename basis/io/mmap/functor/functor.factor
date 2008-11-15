! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors accessors alien.c-types math kernel words ;
IN: io.mmap.functor

SLOT: address
SLOT: length

: mapped-file>direct ( mapped-file type -- alien length )
    [ [ address>> ] [ length>> ] bi ] dip
    heap-size [ 1- + ] keep /i ;

FUNCTOR: mapped-array-functor ( T -- )

C   DEFINES <mapped-${T}-array>
<A> IS      <direct-${T}-array>

WHERE

: C mapped-file>direct <A> execute ; inline

;FUNCTOR
