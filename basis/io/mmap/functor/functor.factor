! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.mmap functors accessors alien.c-types math kernel
words fry ;
IN: io.mmap.functor

SLOT: address
SLOT: length

: mapped-file>direct ( mapped-file type -- alien length )
    [ [ address>> ] [ length>> ] bi ] dip
    heap-size [ 1 - + ] keep /i ;

FUNCTOR: define-mapped-array ( T -- )

<mapped-A>                DEFINES <mapped-${T}-array>
<A>                       IS      <direct-${T}-array>
with-mapped-A-file        DEFINES with-mapped-${T}-file
with-mapped-A-file-reader DEFINES with-mapped-${T}-file-reader

WHERE

: <mapped-A> ( mapped-file -- direct-array )
    T mapped-file>direct <A> ; inline

: with-mapped-A-file ( path quot -- )
    '[ <mapped-A> @ ] with-mapped-file ; inline

: with-mapped-A-file-reader ( path quot -- )
    '[ <mapped-A> @ ] with-mapped-file-reader ; inline

;FUNCTOR
