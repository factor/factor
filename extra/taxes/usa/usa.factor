! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order sequences ;
USE: taxes.usa.w4
IN: taxes.usa

! Withhold: FICA, Medicare, Federal (FICA is social security)

TUPLE: tax-table entity single married ;
C: <tax-table> tax-table

GENERIC: adjust-allowances* ( salary w4 tax-table entity -- newsalary )
GENERIC: withholding* ( salary w4 tax-table entity -- x )

: adjust-allowances ( salary w4 tax-table -- newsalary )
    dup entity>> adjust-allowances* ;

: withholding ( salary w4 tax-table -- x )
    dup entity>> withholding* ;

: tax-bracket-range ( pair -- n ) first2 swap - ;

: tax-bracket ( tax salary triples -- tax salary )
    [ [ tax-bracket-range min ] keep third * + ] 2keep
    tax-bracket-range [-] ;

: tax ( salary triples -- x )
    0 -rot [ tax-bracket ] each drop ;

: marriage-table ( w4 tax-table -- triples )
    swap married?>>
    [ married>> ] [ single>> ] if ;
