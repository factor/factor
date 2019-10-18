! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: laplacian
USING: arrays hopf kernel namespaces sequences topology ;

! Some words for computing the Hodge star map (*), and the
! Laplacian.

: (star) ( term -- term )
    generators get [ swap member? not ] subset-with
    1 swap (odd*) h* ;

: star ( x -- *x )
    >h [ first (star) ] linear-op ;
